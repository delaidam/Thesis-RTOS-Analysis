import re
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import seaborn as sns
from datetime import datetime
import argparse
import os

class SchedulerAnalyzer:
    def __init__(self, log_file):
        self.log_file = log_file
        self.reports = []
        self.task_data = {'HIGH': [], 'MEDIUM': [], 'LOW': []}
        self.system_data = []
        
    def parse_log(self):
        """Parse the FreeRTOS scheduler log file"""
        with open(self.log_file, 'r') as f:
            content = f.read()
        
        # Find all performance reports
        report_pattern = r'=== REALISTIC SCHEDULER PERFORMANCE REPORT ===.*?====================================='
        reports = re.findall(report_pattern, content, re.DOTALL)
        
        for i, report in enumerate(reports):
            report_data = self._parse_single_report(report, i+1)
            if report_data:
                self.reports.append(report_data)
                
        print(f"✅ Parsed {len(self.reports)} performance reports from {self.log_file}")
        return len(self.reports) > 0
    
    def _parse_single_report(self, report, report_num):
        """Parse a single performance report"""
        data = {'report_number': report_num}
        
        # Extract system uptime
        uptime_match = re.search(r'System uptime: (\d+) ticks', report)
        if uptime_match:
            data['uptime_ticks'] = int(uptime_match.group(1))
        
        # Extract task data
        tasks = ['HIGH', 'MEDIUM', 'LOW']
        for task in tasks:
            task_pattern = rf'Task {task} \(Priority (\d+), Period (\d+)ms\):\s+Executions: (\d+)\s+Avg execution time: (\d+) ticks\s+Min execution time: (\d+) ticks\s+Max execution time: (\d+) ticks.*?\s+CPU Utilization: (\d+)%'
            match = re.search(task_pattern, report, re.DOTALL)
            
            if match:
                data[f'{task}_priority'] = int(match.group(1))
                data[f'{task}_period'] = int(match.group(2))
                data[f'{task}_executions'] = int(match.group(3))
                data[f'{task}_avg_time'] = int(match.group(4))
                data[f'{task}_min_time'] = int(match.group(5))
                data[f'{task}_max_time'] = int(match.group(6))
                data[f'{task}_utilization'] = int(match.group(7))
        
        # Extract total utilization and schedulability
        total_util_match = re.search(r'Total CPU Utilization: (\d+)\.(\d+)%', report)
        if total_util_match:
            data['total_utilization'] = float(f"{total_util_match.group(1)}.{total_util_match.group(2)}")
        
        schedulable_match = re.search(r'RESULT: (SCHEDULABLE|NOT SCHEDULABLE)!', report)
        if schedulable_match:
            data['schedulable'] = schedulable_match.group(1) == 'SCHEDULABLE'
        
        # Extract context switches
        context_match = re.search(r'Context switches: (\d+)', report)
        if context_match:
            data['context_switches'] = int(context_match.group(1))
            
        return data
    
    def create_visualizations(self):
        """Create comprehensive performance visualizations"""
        if not self.reports:
            print("❌ No data to visualize!")
            return
        
        # Create DataFrame for easier manipulation
        df = pd.DataFrame(self.reports)
        
        # Set up the plotting style for professional look
        plt.style.use('default')
        sns.set_palette("Set2")
        
        # Create figure with subplots - larger figure for better readability
        fig = plt.figure(figsize=(24, 18))
        fig.suptitle('FreeRTOS Real-Time Scheduler Performance Analysis\n' + 
                    f'Log File: {os.path.basename(self.log_file)}', 
                    fontsize=28, fontweight='bold', y=0.98)
        
        # Custom color scheme
        task_colors = {'HIGH': '#e74c3c', 'MEDIUM': '#f39c12', 'LOW': '#3498db'}
        
        # 1. CPU Utilization Over Time - Main Performance Graph
        ax1 = plt.subplot(3, 4, (1, 2))  # Span 2 columns
        report_nums = df['report_number']
        
        # Plot individual task utilizations
        plt.plot(report_nums, df['HIGH_utilization'], 'o-', linewidth=4, markersize=10, 
                label='HIGH Priority Task', color=task_colors['HIGH'])
        plt.plot(report_nums, df['MEDIUM_utilization'], 's-', linewidth=4, markersize=10, 
                label='MEDIUM Priority Task', color=task_colors['MEDIUM'])
        plt.plot(report_nums, df['LOW_utilization'], '^-', linewidth=4, markersize=10, 
                label='LOW Priority Task', color=task_colors['LOW'])
        
        # Plot total utilization with special emphasis
        plt.plot(report_nums, df['total_utilization'], 'D-', linewidth=6, markersize=12, 
                label='Total CPU Utilization', color='#2ecc71', alpha=0.8)
        
        # Add Rate Monotonic bound line
        plt.axhline(y=78, color='red', linestyle='--', linewidth=3, alpha=0.8, 
                   label='Rate Monotonic Bound (78%)')
        
        plt.title('CPU Utilization Trends Over Time', fontsize=20, fontweight='bold', pad=20)
        plt.xlabel('Report Number', fontsize=16)
        plt.ylabel('CPU Utilization (%)', fontsize=16)
        plt.legend(loc='upper right', fontsize=12)
        plt.grid(True, alpha=0.4)
        plt.ylim(0, max(90, df['total_utilization'].max() + 5))
        
        # Add performance annotation
        initial_util = df['total_utilization'].iloc[0]
        final_util = df['total_utilization'].iloc[-1]
        improvement = initial_util - final_util
        plt.text(0.02, 0.95, f'Performance Improvement: {improvement:.1f}%\n' + 
                f'Final Utilization: {final_util:.1f}%', 
                transform=ax1.transAxes, fontsize=12, fontweight='bold',
                bbox=dict(boxstyle="round,pad=0.3", facecolor="lightgreen", alpha=0.7))
        
        # 2. Execution Time Analysis
        ax2 = plt.subplot(3, 4, 3)
        tasks = ['HIGH', 'MEDIUM', 'LOW']
        
        x = np.arange(len(report_nums))
        width = 0.25
        
        for i, task in enumerate(tasks):
            avg_times = df[f'{task}_avg_time']
            plt.bar(x + i*width, avg_times, width, 
                   label=f'{task}', color=task_colors[task], alpha=0.8)
        
        plt.title('Average Execution Times', fontsize=16, fontweight='bold', pad=15)
        plt.xlabel('Report Number', fontsize=12)
        plt.ylabel('Execution Time (ticks)', fontsize=12)
        plt.xticks(x + width, report_nums)
        plt.legend(fontsize=10)
        plt.grid(True, alpha=0.3, axis='y')
        
        # 3. WCET (Worst Case Execution Time) Analysis
        ax3 = plt.subplot(3, 4, 4)
        for task in tasks:
            min_times = df[f'{task}_min_time']
            max_times = df[f'{task}_max_time']
            avg_times = df[f'{task}_avg_time']
            
            plt.fill_between(report_nums, min_times, max_times, alpha=0.3, 
                           color=task_colors[task], label=f'{task} Range')
            plt.plot(report_nums, avg_times, 'o-', color=task_colors[task], 
                    linewidth=3, markersize=6, label=f'{task} Average')
        
        plt.title('Execution Time Ranges', fontsize=16, fontweight='bold', pad=15)
        plt.xlabel('Report Number', fontsize=12)
        plt.ylabel('Execution Time (ticks)', fontsize=12)
        plt.legend(fontsize=9)
        plt.grid(True, alpha=0.3)
        
        # 4. Task Execution Counts
        ax4 = plt.subplot(3, 4, 5)
        for task in tasks:
            executions = df[f'{task}_executions']
            plt.plot(report_nums, executions, 'o-', linewidth=3, markersize=8, 
                    label=f'{task} Task', color=task_colors[task])
        
        plt.title('Task Execution Counts', fontsize=16, fontweight='bold', pad=15)
        plt.xlabel('Report Number', fontsize=12)
        plt.ylabel('Number of Executions', fontsize=12)
        plt.legend(fontsize=10)
        plt.grid(True, alpha=0.3)
        
        # 5. Context Switches and System Efficiency
        ax5 = plt.subplot(3, 4, 6)
        uptime_seconds = df['uptime_ticks'] / 100  # Assuming 100 ticks per second
        context_rate = df['context_switches'] / uptime_seconds
        
        plt.plot(report_nums, context_rate, 'o-', linewidth=3, markersize=8, 
                color='#9b59b6', label='Context Switch Rate')
        plt.title('Context Switch Rate', fontsize=16, fontweight='bold', pad=15)
        plt.xlabel('Report Number', fontsize=12)
        plt.ylabel('Context Switches per Second', fontsize=12)
        plt.legend(fontsize=10)
        plt.grid(True, alpha=0.3)
        
        # 6. System Uptime
        ax6 = plt.subplot(3, 4, 7)
        plt.plot(report_nums, uptime_seconds, 'o-', linewidth=3, markersize=8, 
                color='#1abc9c', label='System Uptime')
        plt.title('System Uptime', fontsize=16, fontweight='bold', pad=15)
        plt.xlabel('Report Number', fontsize=12)
        plt.ylabel('Uptime (seconds)', fontsize=12)
        plt.legend(fontsize=10)
        plt.grid(True, alpha=0.3)
        
        # 7. Utilization Distribution (Final Report) - Pie Chart
        ax7 = plt.subplot(3, 4, 8)
        final_utils = [df['HIGH_utilization'].iloc[-1], 
                      df['MEDIUM_utilization'].iloc[-1], 
                      df['LOW_utilization'].iloc[-1]]
        colors = [task_colors[task] for task in tasks]
        
        wedges, texts, autotexts = plt.pie(final_utils, labels=tasks, colors=colors, 
                                          autopct='%1.1f%%', startangle=90,
                                          textprops={'fontsize': 12, 'fontweight': 'bold'})
        plt.title('Final CPU Utilization Distribution', fontsize=16, fontweight='bold', pad=15)
        
        # 8. Schedulability Status Timeline
        ax8 = plt.subplot(3, 4, 9)
        schedulable_values = [1 if s else 0 for s in df['schedulable']]
        colors_sched = ['#2ecc71' if s else '#e74c3c' for s in df['schedulable']]
        
        bars = plt.bar(report_nums, schedulable_values, color=colors_sched, alpha=0.8, width=0.6)
        plt.title('Schedulability Status', fontsize=16, fontweight='bold', pad=15)
        plt.xlabel('Report Number', fontsize=12)
        plt.ylabel('Schedulable', fontsize=12)
        plt.ylim(0, 1.2)
        plt.yticks([0, 1], ['NOT SCHEDULABLE', 'SCHEDULABLE'])
        
        # Add status text on bars
        for i, (bar, schedulable) in enumerate(zip(bars, df['schedulable'])):
            status_text = '✓' if schedulable else '✗'
            plt.text(bar.get_x() + bar.get_width()/2, 0.5, status_text, 
                    ha='center', va='center', fontweight='bold', fontsize=20)
        
        # 9. Performance Efficiency Metrics
        ax9 = plt.subplot(3, 4, 10)
        total_executions = df['HIGH_executions'] + df['MEDIUM_executions'] + df['LOW_executions']
        efficiency = total_executions / df['context_switches'] * 100
        
        plt.plot(report_nums, efficiency, 'o-', linewidth=3, markersize=8, 
                color='#e67e22', label='Task Efficiency')
        plt.title('System Efficiency', fontsize=16, fontweight='bold', pad=15)
        plt.xlabel('Report Number', fontsize=12)
        plt.ylabel('Efficiency (%)', fontsize=12)
        plt.legend(fontsize=10)
        plt.grid(True, alpha=0.3)
        
        # 10. Real-time Performance Metrics
        ax10 = plt.subplot(3, 4, 11)
        # Calculate deadline miss probability (simplified metric)
        for task in tasks:
            period_ticks = df[f'{task}_period'].iloc[0] * 1  # Assuming 1 tick per ms
            wcet_ratio = df[f'{task}_max_time'] / period_ticks * 100
            plt.plot(report_nums, wcet_ratio, 'o-', linewidth=3, markersize=6,
                    label=f'{task} WCET/Period %', color=task_colors[task])
        
        plt.title('WCET to Period Ratio', fontsize=16, fontweight='bold', pad=15)
        plt.xlabel('Report Number', fontsize=12)
        plt.ylabel('WCET/Period (%)', fontsize=12)
        plt.legend(fontsize=9)
        plt.grid(True, alpha=0.3)
        
        # 11. Performance Summary Table
        ax11 = plt.subplot(3, 4, 12)
        ax11.axis('tight')
        ax11.axis('off')
        
        # Create comprehensive summary statistics
        summary_data = []
        for task in tasks:
            avg_util = df[f'{task}_utilization'].mean()
            std_util = df[f'{task}_utilization'].std()
            avg_exec = df[f'{task}_avg_time'].mean()
            max_exec = df[f'{task}_max_time'].max()
            total_exec = df[f'{task}_executions'].iloc[-1]
            
            summary_data.append([
                task, 
                f"{avg_util:.1f}±{std_util:.1f}%",
                f"{avg_exec:.1f}",
                f"{max_exec}",
                f"{total_exec}"
            ])
        
        # Add system totals
        avg_total_util = df['total_utilization'].mean()
        std_total_util = df['total_utilization'].std()
        final_context_switches = df['context_switches'].iloc[-1]
        uptime_final = df['uptime_ticks'].iloc[-1] / 100
        
        summary_data.append([
            'SYSTEM',
            f"{avg_total_util:.1f}±{std_total_util:.1f}%",
            f"{uptime_final:.1f}s",
            f"{final_context_switches}",
            '✓' if all(df['schedulable']) else '✗'
        ])
        
        table = ax11.table(cellText=summary_data,
                          colLabels=['Task', 'CPU% (μ±σ)', 'Avg Exec', 'WCET', 'Count/Status'],
                          cellLoc='center',
                          loc='center',
                          colColours=['#ecf0f1']*5)
        table.auto_set_font_size(False)
        table.set_fontsize(11)
        table.scale(1.2, 2.5)
        ax11.set_title('Performance Summary Statistics', fontsize=16, fontweight='bold', pad=15)
        
        plt.tight_layout(rect=[0, 0.03, 1, 0.93])
        
        # Save the plot with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        log_basename = os.path.splitext(os.path.basename(self.log_file))[0]
        filename = f'scheduler_analysis_{log_basename}_{timestamp}.png'
        plt.savefig(filename, dpi=300, bbox_inches='tight', facecolor='white')
        print(f"📊 Comprehensive analysis saved as: {filename}")
        
        plt.show()
    
    def generate_report(self):
        """Generate a detailed text report"""
        if not self.reports:
            print("❌ No data to analyze!")
            return
        
        df = pd.DataFrame(self.reports)
        
        print("\n" + "="*100)
        print(" "*25 + "FREERTOS REAL-TIME SCHEDULER PERFORMANCE ANALYSIS")
        print("="*100)
        
        print(f"\n📋 ANALYSIS METADATA:")
        print(f"   ├─ Analysis Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"   ├─ Log File: {self.log_file}")
        print(f"   ├─ Total Reports: {len(self.reports)}")
        print(f"   └─ Analysis Duration: {df['uptime_ticks'].iloc[-1]/100:.1f} seconds")
        
        # Overall system assessment
        all_schedulable = all(df['schedulable'])
        avg_util = df['total_utilization'].mean()
        util_stability = df['total_utilization'].std()
        
        print(f"\n🎯 SYSTEM OVERVIEW:")
        status_emoji = "🟢" if all_schedulable else "🔴"
        print(f"   ├─ {status_emoji} Schedulability: {'✅ FULLY SCHEDULABLE' if all_schedulable else '❌ ISSUES DETECTED'}")
        print(f"   ├─ 📊 Average CPU Utilization: {avg_util:.1f}% (σ={util_stability:.2f}%)")
        print(f"   ├─ 🎚️  Rate Monotonic Bound: 78.0%")
        print(f"   ├─ 📈 Performance Trend: {'🔽 IMPROVING' if df['total_utilization'].iloc[-1] < df['total_utilization'].iloc[0] else '📊 STABLE'}")
        print(f"   └─ ⚡ Final Utilization: {df['total_utilization'].iloc[-1]:.1f}%")
        
        print(f"\n📈 DETAILED TASK ANALYSIS:")
        tasks = ['HIGH', 'MEDIUM', 'LOW']
        priorities = {task: df[f'{task}_priority'].iloc[0] for task in tasks}
        periods = {task: df[f'{task}_period'].iloc[0] for task in tasks}
        
        for task in tasks:
            print(f"\n   🔹 {task} Priority Task (P={priorities[task]}, T={periods[task]}ms):")
            
            avg_util = df[f'{task}_utilization'].mean()
            util_std = df[f'{task}_utilization'].std()
            avg_exec = df[f'{task}_avg_time'].mean()
            exec_std = df[f'{task}_avg_time'].std()
            min_exec = df[f'{task}_min_time'].min()
            max_exec = df[f'{task}_max_time'].max()
            total_exec = df[f'{task}_executions'].iloc[-1]
            
            # Performance assessment
            util_assessment = "🟢 EXCELLENT" if avg_util < 30 else "🟡 GOOD" if avg_util < 50 else "🟠 HIGH"
            stability = "🟢 STABLE" if util_std < 2.0 else "🟡 VARIABLE"
            
            print(f"      ├─ CPU Utilization: {avg_util:.1f}% ± {util_std:.2f}% ({util_assessment})")
            print(f"      ├─ Execution Time: {avg_exec:.1f} ± {exec_std:.2f} ticks")
            print(f"      ├─ BCET/WCET: {min_exec}/{max_exec} ticks (Jitter: {max_exec-min_exec} ticks)")
            print(f"      ├─ Total Executions: {total_exec}")
            print(f"      ├─ Execution Rate: {total_exec/(df['uptime_ticks'].iloc[-1]/100):.1f} Hz")
            print(f"      └─ Stability: {stability}")
        
        print(f"\n⚡ REAL-TIME PERFORMANCE METRICS:")
        context_rate = df['context_switches'].iloc[-1] / (df['uptime_ticks'].iloc[-1] / 100)
        total_tasks = sum(df[f'{task}_executions'].iloc[-1] for task in tasks)
        
        print(f"   ├─ Context Switch Rate: {context_rate:.1f} switches/second")
        print(f"   ├─ Task Throughput: {total_tasks/(df['uptime_ticks'].iloc[-1]/100):.1f} tasks/second")
        print(f"   ├─ System Efficiency: {(total_tasks/df['context_switches'].iloc[-1]*100):.1f}%")
        
        # Deadline analysis
        print(f"   └─ Worst-Case Response Times:")
        for task in tasks:
            period_ms = periods[task]
            wcet_ticks = df[f'{task}_max_time'].max()
            wcet_ms = wcet_ticks  # Assuming 1 tick = 1ms
            margin = period_ms - wcet_ms
            margin_percent = (margin / period_ms) * 100
            
            margin_status = "🟢 SAFE" if margin_percent > 50 else "🟡 ADEQUATE" if margin_percent > 20 else "🔴 TIGHT"
            print(f"        ├─ {task}: {wcet_ms}ms / {period_ms}ms ({margin_percent:.1f}% margin) {margin_status}")
        
        print(f"\n🔧 PERFORMANCE OPTIMIZATION INSIGHTS:")
        
        # Utilization efficiency
        if avg_util < 50:
            print(f"   ├─ ✅ System is well-optimized with {78-avg_util:.1f}% utilization headroom")
            print(f"   ├─ 💡 Can accommodate additional tasks or increase existing workloads")
        elif avg_util < 65:
            print(f"   ├─ ⚠️  System utilization is moderate - monitor for task additions")
        else:
            print(f"   ├─ 🚨 High utilization detected - consider task optimization")
        
        # Stability analysis
        if util_stability < 2.0:
            print(f"   ├─ 📊 Excellent stability (σ={util_stability:.2f}% variation)")
        else:
            print(f"   ├─ ⚠️  Utilization variability detected - investigate workload patterns")
        
        # Scheduler efficiency
        if all_schedulable:
            print(f"   ├─ 🎯 Rate Monotonic Scheduling: OPTIMAL")
            print(f"   └─ 🏆 System meets all real-time constraints")
        else:
            print(f"   ├─ ⚠️  Schedulability issues detected")
            print(f"   └─ 🔧 Consider task period adjustments or workload optimization")
        
        print(f"\n🎖️  FINAL ASSESSMENT:")
        if all_schedulable and avg_util < 60 and util_stability < 3.0:
            grade = "🏆 EXCELLENT"
            recommendation = "System demonstrates outstanding real-time performance"
        elif all_schedulable and avg_util < 75:
            grade = "✅ GOOD"
            recommendation = "System meets requirements with good performance margins"
        elif all_schedulable:
            grade = "⚠️  ACCEPTABLE"
            recommendation = "System is schedulable but approaching limits"
        else:
            grade = "❌ NEEDS IMPROVEMENT"
            recommendation = "System requires optimization to meet real-time constraints"
        
        print(f"   ├─ Overall Grade: {grade}")
        print(f"   └─ Recommendation: {recommendation}")
        
        print("\n" + "="*100)

def main():
    parser = argparse.ArgumentParser(description='Analyze FreeRTOS Scheduler Performance Log')
    parser.add_argument('log_file', help='Path to scheduler log file (e.g., scheduler_run_10.log)')
    parser.add_argument('--report-only', action='store_true', help='Generate text report only (no graphs)')
    parser.add_argument('--save-data', action='store_true', help='Save parsed data as CSV')
    
    args = parser.parse_args()
    
    if not os.path.exists(args.log_file):
        print(f"❌ Error: Log file '{args.log_file}' not found!")
        return
    
    print(f"🚀 Starting analysis of {args.log_file}...")
    analyzer = SchedulerAnalyzer(args.log_file)
    
    if analyzer.parse_log():
        if not args.report_only:
            print("📊 Generating comprehensive visualizations...")
            analyzer.create_visualizations()
        
        print("📋 Generating detailed performance report...")
        analyzer.generate_report()
        
        if args.save_data:
            # Save parsed data for further analysis
            df = pd.DataFrame(analyzer.reports)
            csv_filename = f"scheduler_data_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
            df.to_csv(csv_filename, index=False)
            print(f"💾 Raw data saved as: {csv_filename}")
            
    else:
        print("❌ Failed to parse log file!")

if __name__ == "__main__":
    main()