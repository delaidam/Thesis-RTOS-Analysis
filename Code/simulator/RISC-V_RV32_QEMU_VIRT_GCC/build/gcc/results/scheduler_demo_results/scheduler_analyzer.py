import re
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import seaborn as sns
from datetime import datetime
import argparse
import os
import sys
import json

# Set console encoding for Windows compatibility
if sys.platform.startswith('win'):
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

class SchedulerAnalyzer:
    def __init__(self, log_file):
        self.log_file = log_file
        self.reports = []
        self.task_data = {'HIGH': [], 'MEDIUM': [], 'LOW': []}
        self.system_data = []
        
    def parse_log(self):
        """Parse the FreeRTOS scheduler log file"""
        try:
            with open(self.log_file, 'r', encoding='utf-8') as f:
                content = f.read()
        except UnicodeDecodeError:
            with open(self.log_file, 'r', encoding='latin-1') as f:
                content = f.read()
        
        # Debug: Show first part of content
        print(f"[DEBUG] Total log length: {len(content)} characters")
        
        report_pattern = r'=== SCHEDULER PERFORMANCE REPORT ===.*?============================================\n'
        reports = re.findall(report_pattern, content, re.DOTALL)
        
        print(f"[DEBUG] Found {len(reports)} report matches using current pattern")
        
        if len(reports) == 0 or (len(reports) > 0 and len(reports[0]) < 200):
            print("[DEBUG] Trying alternative pattern...")
            report_pattern2 = r'============================================\n=== REALISTIC SCHEDULER PERFORMANCE REPORT ===.*?============================================\n'
            reports = re.findall(report_pattern2, content, re.DOTALL)
            print(f"[DEBUG] Alternative pattern found {len(reports)} reports")
        
        if len(reports) == 0 or (len(reports) > 0 and len(reports[0]) < 200):
            print("[DEBUG] Trying manual split approach...")
            parts = content.split('=== REALISTIC SCHEDULER PERFORMANCE REPORT ===')
            reports = []
            for i in range(1, len(parts)):
                report_content = '=== REALISTIC SCHEDULER PERFORMANCE REPORT ===' + parts[i]
                end_marker = report_content.find('============================================', 100)  
                if end_marker != -1:
                    line_end = report_content.find('\n', end_marker)
                    if line_end != -1:
                        report_content = report_content[:line_end+1]
                reports.append(report_content)
            print(f"[DEBUG] Manual split found {len(reports)} reports")
        
        if len(reports) > 0:
            print(f"[DEBUG] First report length: {len(reports[0])}")
            print(f"[DEBUG] First report content (first 500 chars):")
            print(repr(reports[0][:500]))
        
        for i, report in enumerate(reports):
            report_data = self._parse_single_report(report, i+1)
            if report_data and len(report_data) > 1:  # More than just report_number
                self.reports.append(report_data)
                
        print(f"[OK] Successfully parsed {len(self.reports)} complete performance reports from {self.log_file}")
        return len(self.reports) > 0
    
    def _parse_single_report(self, report, report_num):
        """Parse a single performance report with proper task-specific parsing"""
        data = {'report_number': report_num}
        
        print(f"[DEBUG] Parsing report {report_num}, content length: {len(report)}")
        
        # Extract system uptime
        uptime_match = re.search(r'System uptime: (\d+) ticks', report)
        if uptime_match:
            data['uptime_ticks'] = int(uptime_match.group(1))
            print(f"[DEBUG] Found uptime: {data['uptime_ticks']}")
        
        # Extract task data - FIXED APPROACH
        # Split report into lines and process task sections properly
        lines = report.split('\n')
        
        tasks = ['HIGH', 'MEDIUM', 'LOW']
        for task in tasks:
            print(f"[DEBUG] Processing {task} task...")
            
            # Find the task header line
            task_header_line = None
            for i, line in enumerate(lines):
                if f'Task {task} (Priority' in line and 'Period' in line:
                    task_header_line = i
                    print(f"[DEBUG] Found {task} header at line {i}: {line.strip()}")
                    break
            
            if task_header_line is not None:
                # Extract priority and period from header
                header_match = re.search(rf'Task {task} \(Priority (\d+), Period (\d+)ms\):', lines[task_header_line])
                if header_match:
                    data[f'{task}_priority'] = int(header_match.group(1))
                    data[f'{task}_period'] = int(header_match.group(2))
                    print(f"[DEBUG] {task}: Priority={data[f'{task}_priority']}, Period={data[f'{task}_period']}")
                
                # Look for task metrics in the following lines (usually within next 10 lines)
                search_end = min(task_header_line + 15, len(lines))
                task_section = '\n'.join(lines[task_header_line:search_end])
                print(f"[DEBUG] {task} section content:\n{task_section}")
                
                # Extract metrics from this specific task section
                exec_match = re.search(r'Executions: (\d+)', task_section)
                if exec_match:
                    data[f'{task}_executions'] = int(exec_match.group(1))
                    print(f"[DEBUG] {task} executions: {data[f'{task}_executions']}")
                
                avg_match = re.search(r'Avg execution time: (\d+) ticks', task_section)
                if avg_match:
                    data[f'{task}_avg_time'] = int(avg_match.group(1))
                    print(f"[DEBUG] {task} avg time: {data[f'{task}_avg_time']}")
                
                min_match = re.search(r'Min execution time: (\d+) ticks', task_section)
                if min_match:
                    data[f'{task}_min_time'] = int(min_match.group(1))
                    print(f"[DEBUG] {task} min time: {data[f'{task}_min_time']}")
                
                max_match = re.search(r'Max execution time: (\d+) ticks.*?WCET', task_section, re.DOTALL)
                if max_match:
                    # Extract just the number before " ticks"
                    max_time_match = re.search(r'Max execution time: (\d+) ticks', task_section)
                    if max_time_match:
                        data[f'{task}_max_time'] = int(max_time_match.group(1))
                        print(f"[DEBUG] {task} max time: {data[f'{task}_max_time']}")
                
                util_match = re.search(r'CPU Utilization: (\d+)%', task_section)
                if util_match:
                    data[f'{task}_utilization'] = int(util_match.group(1))
                    print(f"[DEBUG] {task} utilization: {data[f'{task}_utilization']}")
                
                # Count successful extractions
                extracted_count = sum(1 for key in [f'{task}_executions', f'{task}_avg_time', 
                                                  f'{task}_min_time', f'{task}_max_time', f'{task}_utilization'] 
                                    if key in data)
                print(f"[DEBUG] {task}: extracted {extracted_count}/5 metrics")
            else:
                print(f"[DEBUG] No {task} header found in report")
        
        # Extract total utilization and schedulability - from the end of report
        total_util_match = re.search(r'Total CPU Utilization: (\d+)\.(\d+)%', report)
        if total_util_match:
            data['total_utilization'] = float(f"{total_util_match.group(1)}.{total_util_match.group(2)}")
            print(f"[DEBUG] Found total utilization: {data['total_utilization']}")
        
        schedulable_match = re.search(r'RESULT: (SCHEDULABLE|NOT SCHEDULABLE)!', report)
        if schedulable_match:
            data['schedulable'] = schedulable_match.group(1) == 'SCHEDULABLE'
            print(f"[DEBUG] Found schedulability: {data['schedulable']}")
        
        # Extract context switches
        context_match = re.search(r'Context switches: (\d+)', report)
        if context_match:
            data['context_switches'] = int(context_match.group(1))
            print(f"[DEBUG] Found context switches: {data['context_switches']}")
        
        # Final validation - check if we have reasonable data
        task_data_count = sum(1 for key in data.keys() if any(task in key for task in tasks))
        print(f"[DEBUG] Report {report_num} final data: {len(data)} total keys, {task_data_count} task-specific keys")
        
        # Print summary of what was extracted
        for task in tasks:
            if f'{task}_utilization' in data:
                print(f"[DEBUG] {task} SUMMARY: util={data.get(f'{task}_utilization', 'N/A')}%, "
                      f"exec={data.get(f'{task}_executions', 'N/A')}, "
                      f"avg={data.get(f'{task}_avg_time', 'N/A')} ticks")
        
        return data
    
    def create_visualizations(self):
        """Create and save each performance visualization as a separate figure (in English)"""
        if not self.reports:
            print("[ERROR] No data to visualize!")
            return

        df = pd.DataFrame(self.reports)
        report_nums = df['report_number']
        tasks = ['HIGH', 'MEDIUM', 'LOW']
        task_colors = {'HIGH': '#e74c3c', 'MEDIUM': '#f39c12', 'LOW': '#3498db'}

        # 1. CPU Utilization Trends Over Time
        plt.figure()
        ax1 = plt.subplot(1, 1, 1)
        plt.plot(report_nums, df['HIGH_utilization'], 'o-', linewidth=3, markersize=8, label='HIGH Priority Task', color=task_colors['HIGH'])
        plt.plot(report_nums, df['MEDIUM_utilization'], 's-', linewidth=3, markersize=8, label='MEDIUM Priority Task', color=task_colors['MEDIUM'])
        plt.plot(report_nums, df['LOW_utilization'], '^-', linewidth=3, markersize=8, label='LOW Priority Task', color=task_colors['LOW'])
        plt.plot(report_nums, df['total_utilization'], 'D-', linewidth=4, markersize=10, label='Total CPU Utilization', color='#2ecc71', alpha=0.8)
        plt.axhline(y=78, color='red', linestyle='--', linewidth=2, alpha=0.8, label='Rate Monotonic Bound (78%)')
        plt.title('CPU Utilization Trends Over Time', fontsize=16, fontweight='bold', pad=15)
        plt.xlabel('Report Number', fontsize=12)
        plt.ylabel('CPU Utilization (%)', fontsize=12)
        plt.legend(loc='upper right', fontsize=10)
        plt.grid(True, alpha=0.4)
        plt.savefig('cpu_utilization_trends.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 2. Average Execution Times
        plt.figure()
        ax2 = plt.subplot(1, 1, 1)
        x = np.arange(len(report_nums))
        width = 0.25
        for i, task in enumerate(tasks):
            avg_times = df[f'{task}_avg_time']
            plt.bar(x + i*width, avg_times, width, label=f'{task}', color=task_colors[task], alpha=0.8)
        plt.title('Average Execution Times', fontsize=16, fontweight='bold', pad=15)
        plt.xlabel('Report Number', fontsize=12)
        plt.ylabel('Execution Time (ticks)', fontsize=12)
        plt.legend(fontsize=10, title='Task')
        plt.grid(True, alpha=0.3, axis='y')
        plt.savefig('average_execution_times.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 3. Execution Time Ranges (WCET)
        plt.figure()
        ax3 = plt.subplot(1, 1, 1)
        for task in tasks:
            min_times = df[f'{task}_min_time']
            max_times = df[f'{task}_max_time']
            avg_times = df[f'{task}_avg_time']
            plt.fill_between(report_nums, min_times, max_times, alpha=0.3, color=task_colors[task], label=f'{task} Range')
            plt.plot(report_nums, avg_times, 'o-', color=task_colors[task], linewidth=3, markersize=6, label=f'{task} Average')
        plt.title('Execution Time Ranges', fontsize=16, fontweight='bold', pad=15)
        plt.xlabel('Report Number', fontsize=12)
        plt.ylabel('Execution Time (ticks)', fontsize=12)
        plt.legend(fontsize=9, title='Task')
        plt.grid(True, alpha=0.3)
        plt.savefig('execution_time_ranges.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 4. Task Execution Counts
        plt.figure()
        ax4 = plt.subplot(1, 1, 1)
        for task in tasks:
            executions = df[f'{task}_executions']
            plt.plot(report_nums, executions, 'o-', linewidth=3, markersize=8, label=f'{task} Task', color=task_colors[task])
        plt.title('Task Execution Counts', fontsize=16, fontweight='bold', pad=15)
        plt.xlabel('Report Number', fontsize=12)
        plt.ylabel('Execution Count', fontsize=12)
        plt.legend(fontsize=10, title='Task')
        plt.grid(True, alpha=0.3)
        plt.savefig('task_execution_counts.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 5. Context Switch Rate
        plt.figure()
        ax5 = plt.subplot(1, 1, 1)
        uptime_seconds = df['uptime_ticks'] / 100  # Assuming 100 ticks per second
        context_rate = df['context_switches'] / uptime_seconds
        plt.plot(report_nums, context_rate, 'o-', linewidth=3, markersize=8, color='#9b59b6', label='Context Switch Rate')
        plt.title('Context Switch Rate', fontsize=16, fontweight='bold', pad=15)
        plt.xlabel('Report Number', fontsize=12)
        plt.ylabel('Switches/s', fontsize=12)
        plt.legend(fontsize=10)
        plt.grid(True, alpha=0.3)
        plt.savefig('context_switch_rate.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 6. System Uptime
        plt.figure()
        ax6 = plt.subplot(1, 1, 1)
        plt.plot(report_nums, uptime_seconds, 'o-', linewidth=3, markersize=8, color='#1abc9c', label='System Uptime')
        plt.title('System Uptime', fontsize=16, fontweight='bold', pad=15)
        plt.xlabel('Report Number', fontsize=12)
        plt.ylabel('Uptime (seconds)', fontsize=12)
        plt.legend(fontsize=10)
        plt.grid(True, alpha=0.3)
        plt.savefig('system_uptime.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 7. Utilization Distribution (Pie Chart)
        plt.figure()
        ax7 = plt.subplot(1, 1, 1)
        final_utils = [df['HIGH_utilization'].iloc[-1], df['MEDIUM_utilization'].iloc[-1], df['LOW_utilization'].iloc[-1]]
        colors = [task_colors[task] for task in tasks]
        wedges, texts, autotexts = plt.pie(final_utils, labels=tasks, colors=colors, autopct='%1.1f%%', startangle=90,
                                       textprops={'fontsize': 12, 'fontweight': 'bold'})
        plt.title('CPU Utilization Distribution', fontsize=16, fontweight='bold', pad=15)
        plt.savefig('cpu_utilization_distribution.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 8. Schedulability Status Timeline
        plt.figure()
        ax8 = plt.subplot(1, 1, 1)
        schedulable_values = [1 if s else 0 for s in df['schedulable']]
        colors_sched = ['#2ecc71' if s else '#e74c3c' for s in df['schedulable']]
        bars = plt.bar(report_nums, schedulable_values, color=colors_sched, alpha=0.8, width=0.6)
        plt.title('Schedulability Status', fontsize=16, fontweight='bold', pad=15)
        plt.xlabel('Report Number', fontsize=12)
        plt.ylabel('Schedulability', fontsize=12)
        plt.yticks([0, 1], ['NOT SCHEDULABLE', 'SCHEDULABLE'])
        for i, (bar, schedulable) in enumerate(zip(bars, df['schedulable'])):
            status_text = 'YES' if schedulable else 'NO'
            plt.text(bar.get_x() + bar.get_width()/2, 0.5, status_text, ha='center', va='center', fontweight='bold', fontsize=12)
        plt.savefig('schedulability_status.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 9. Performance Summary Table
        plt.figure()
        ax9 = plt.subplot(1, 1, 1)
        ax9.axis('tight')
        ax9.axis('off')
        summary_data = []
        for task in tasks:
            avg_util = df[f'{task}_utilization'].mean()
            avg_exec = df[f'{task}_avg_time'].mean()
            max_exec = df[f'{task}_max_time'].max()
            total_exec = df[f'{task}_executions'].iloc[-1]
            summary_data.append([
                task,
                f"{avg_util:.1f}%",
                f"{avg_exec:.1f}",
                f"{max_exec}",
                f"{total_exec}"
            ])
        avg_total_util = df['total_utilization'].mean()
        final_context_switches = df['context_switches'].iloc[-1]
        uptime_final = df['uptime_ticks'].iloc[-1] / 100
        summary_data.append([
            'SYSTEM',
            f"{avg_total_util:.1f}%",
            f"{uptime_final:.1f}s",
            f"{final_context_switches}",
            'OK' if all(df['schedulable']) else 'FAIL'
        ])
        table = ax9.table(cellText=summary_data,
                          colLabels=['Task', 'CPU%', 'Avg Exec', 'WCET', 'Count/Status'],
                          cellLoc='center',
                          loc='center',
                          colColours=['#ecf0f1']*5)
        table.auto_set_font_size(False)
        table.set_fontsize(11)
        table.scale(1.2, 2.5)
        plt.title('Performance Summary', fontsize=16, fontweight='bold', pad=15)
        plt.savefig('performance_summary.png', dpi=300, bbox_inches='tight')
        plt.close()
    
    def generate_report(self):
        """Generiši detaljan tekstualni izvještaj (na bosanskom jeziku)"""
        if not self.reports:
            print("[GREŠKA] Nema podataka za analizu!")
            return

        df = pd.DataFrame(self.reports)

        print("\n" + "="*80)
        print("    FREERTOS ANALIZA PERFORMANSI REAL-TIME SCHEDULERA")
        print("="*80)

        print(f"\nMETAPODACI O ANALIZI:")
        print(f"  Datum analize: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"  Log datoteka: {self.log_file}")
        print(f"  Ukupno izvještaja: {len(self.reports)}")
        print(f"  Trajanje analize: {df['uptime_ticks'].iloc[-1]/100:.1f} sekundi")

        # Opći pregled sistema
        all_schedulable = all(df['schedulable'])
        avg_util = df['total_utilization'].mean()
        util_stability = df['total_utilization'].std()

        print(f"\nPREGLED SISTEMA:")
        status = "POTPUNO SCHEDULABLE" if all_schedulable else "PRONAĐENI PROBLEMI"
        print(f"  Schedulability: {status}")
        print(f"  Prosječna iskorištenost CPU-a: {avg_util:.1f}% (std={util_stability:.2f}%)")
        print(f"  Rate Monotonic granica: 78.0%")
        trend = "POBOLJŠANJE" if df['total_utilization'].iloc[-1] < df['total_utilization'].iloc[0] else "STABILNO"
        print(f"  Trend performansi: {trend}")
        print(f"  Završna iskorištenost: {df['total_utilization'].iloc[-1]:.1f}%")

        print(f"\nDETALJNA ANALIZA ZADATAKA:")
        tasks = ['HIGH', 'MEDIUM', 'LOW']
        priorities = {task: df[f'{task}_priority'].iloc[0] for task in tasks}
        periods = {task: df[f'{task}_period'].iloc[0] for task in tasks}

        for task in tasks:
            print(f"\n  {task} prioritetni zadatak (P={priorities[task]}, T={periods[task]}ms):")

            avg_util = df[f'{task}_utilization'].mean()
            avg_exec = df[f'{task}_avg_time'].mean()
            min_exec = df[f'{task}_min_time'].min()
            max_exec = df[f'{task}_max_time'].max()
            total_exec = df[f'{task}_executions'].iloc[-1]

            # Procjena performansi
            util_assessment = "ODLIČNO" if avg_util < 30 else "DOBRO" if avg_util < 50 else "VISOKO"

            print(f"    Iskorištenost CPU-a: {avg_util:.1f}% ({util_assessment})")
            print(f"    Vrijeme izvršavanja: {avg_exec:.1f} tickova (prosjek)")
            print(f"    BCET/WCET: {min_exec}/{max_exec} tickova (Jitter: {max_exec-min_exec})")
            print(f"    Ukupno izvršavanja: {total_exec}")
            print(f"    Frekvencija izvršavanja: {total_exec/(df['uptime_ticks'].iloc[-1]/100):.1f} Hz")

        print(f"\nMETRIKE REAL-TIME PERFORMANSI:")
        context_rate = df['context_switches'].iloc[-1] / (df['uptime_ticks'].iloc[-1] / 100)
        total_tasks = sum(df[f'{task}_executions'].iloc[-1] for task in tasks)

        print(f"  Stopa prebacivanja konteksta: {context_rate:.1f} prebacivanja/sekundi")
        print(f"  Propusnost zadataka: {total_tasks/(df['uptime_ticks'].iloc[-1]/100):.1f} zadataka/sekundi")
        print(f"  Efikasnost sistema: {(total_tasks/df['context_switches'].iloc[-1]*100):.1f}%")

        # Analiza deadline-a
        print(f"  Najgora vremena odziva (Worst-Case Response Times):")
        for task in tasks:
            period_ms = periods[task]
            wcet_ticks = df[f'{task}_max_time'].max()
            wcet_ms = wcet_ticks  # Pretpostavka: 1 tick = 1ms
            margin = period_ms - wcet_ms
            margin_percent = (margin / period_ms) * 100

            margin_status = "SIGURNO" if margin_percent > 50 else "DOVOLJNO" if margin_percent > 20 else "KRITIČNO"
            print(f"    {task}: {wcet_ms}ms / {period_ms}ms ({margin_percent:.1f}% margina) {margin_status}")

        print(f"\nZAVRŠNA OCJENA:")
        if all_schedulable and avg_util < 60 and util_stability < 3.0:
            grade = "ODLIČNO"
            recommendation = "Sistem pokazuje izvanredne real-time performanse"
        elif all_schedulable and avg_util < 75:
            grade = "DOBRO"
            recommendation = "Sistem ispunjava zahtjeve sa dobrim marginama"
        elif all_schedulable:
            grade = "PRIHVATLJIVO"
            recommendation = "Sistem je schedulable, ali blizu limita"
        else:
            grade = "POTREBNA OPTIMIZACIJA"
            recommendation = "Sistem zahtijeva optimizaciju za real-time zahtjeve"

        print(f"  Završna ocjena: {grade}")
        print(f"  Preporuka: {recommendation}")

        print("\n" + "="*80)

def save_data_to_json(log_file, data, total_cycles):
    """Save parsed queue data and stats to a JSON file for further analysis."""
    # Pripremi statistiku po prioritetu
    stats = {}
    for priority in data.keys():
        sent = [d["sent"] for d in data[priority]]
        received = [d["received"] for d in data[priority]]
        latency = [d["avg_latency"] for d in data[priority]]
        stats[priority] = {
            "total_sent": sum(sent) if sent else 0,
            "total_received": sum(received) if received else 0,
            "avg_latency": sum(latency) / len(latency) if latency else 0,
            "min_latency": min(latency) if latency else 0,
            "max_latency": max(latency) if latency else 0,
            "throughput": (sum(received) / (total_cycles / 1000)) if (total_cycles and total_cycles > 0) else 0
        }
    # Spremi sve u JSON
    json_file = f"{log_file}_data.json"
    with open(json_file, "w", encoding="utf-8") as f:
        json.dump({"data": data, "total_cycles": total_cycles, "stats": stats}, f, indent=2)
    print(f"[JSON] Data saved as: {json_file}")

def main():
    parser = argparse.ArgumentParser(description='Analyze FreeRTOS Scheduler Performance Log')
    parser.add_argument('log_file', help='Path to scheduler log file (e.g., scheduler_run_10.log)')
    parser.add_argument('--report-only', action='store_true', help='Generate text report only (no graphs)')
    parser.add_argument('--save-data', action='store_true', help='Save parsed data as CSV')
    
    args = parser.parse_args()
    
    if not os.path.exists(args.log_file):
        print(f"[ERROR] Log file '{args.log_file}' not found!")
        return
    
    print(f"[START] Starting analysis of {args.log_file}...")
    analyzer = SchedulerAnalyzer(args.log_file)
    
    if analyzer.parse_log():
        if not args.report_only:
            print("[GRAPHS] Generating comprehensive visualizations...")
            analyzer.create_visualizations()
        
        print("[REPORT] Generating detailed performance report...")
        analyzer.generate_report()
        
        if args.save_data:
            # Save parsed data for further analysis
            df = pd.DataFrame(analyzer.reports)
            csv_filename = f"scheduler_data_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
            df.to_csv(csv_filename, index=False)
            print(f"[CSV] Raw data saved as: {csv_filename}")
            
    else:
        print("[ERROR] Failed to parse log file!")

    log_file = args.log_file
    if os.path.exists(log_file):
        data, total_cycles = parse_queue_log(log_file)
        if any(len(v) > 0 for v in data.values()):  # Provjera da li su podaci parsirani
            save_data_to_json(log_file, data, total_cycles)
            generate_graphs(log_file, data, total_cycles)
            print("Analysis completed!")
        else:
            print("Nema valjanih podataka za analizu.")
    else:
        print(f"Log file not found: {log_file}")

if __name__ == "__main__":
    main()