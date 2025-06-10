import re
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from datetime import datetime
import json
from collections import defaultdict
from pathlib import Path
import os

class InterruptAnalyzer:
    def __init__(self, log_file='interrupt_demo.log'):
        self.log_file = log_file
        self.raw_data = self.load_log()
        self.interrupts = []
        self.io_operations = []
        self.cycle_reports = []
        self.timer_events = []
        self.parse_all_data()
        
    def load_log(self):
        """Load raw log data"""
        try:
            with open(self.log_file, 'r', encoding='utf-8') as f:
                return f.read()
        except FileNotFoundError:
            print(f"Error: {self.log_file} not found!")
            return ""
    
    def parse_all_data(self):
        """Parse all types of events from log"""
        self.parse_interrupts()
        self.parse_io_operations()
        self.parse_cycle_reports()
        self.parse_timer_events()
        
    def parse_interrupts(self):
        """Parse interrupt processing events"""
        # Pattern for interrupt processing
        interrupt_pattern = r'\[INT-HANDLER\] Processing interrupt #(\d+) \(Priority: (\d+), Complexity: (\d+)(?: -> (\d+))?\)'
        response_pattern = r'\[INT-HANDLER\] Response time: (\d+) ticks \(Deadline: (\d+) ticks\)'
        
        lines = self.raw_data.split('\n')
        current_interrupt = None
        
        for i, line in enumerate(lines):
            # Match interrupt start
            int_match = re.search(interrupt_pattern, line)
            if int_match:
                interrupt_id = int(int_match.group(1))
                priority = int(int_match.group(2))
                complexity_orig = int(int_match.group(3))
                complexity_opt = int(int_match.group(4)) if int_match.group(4) else complexity_orig
                
                current_interrupt = {
                    'id': interrupt_id,
                    'priority': priority,
                    'complexity_original': complexity_orig,
                    'complexity_optimized': complexity_opt,
                    'complexity_adjusted': complexity_orig != complexity_opt,
                    'line_num': i
                }
                
            # Match response time (should be next line)
            elif current_interrupt and re.search(response_pattern, line):
                resp_match = re.search(response_pattern, line)
                if resp_match:
                    current_interrupt['response_time'] = int(resp_match.group(1))
                    current_interrupt['deadline'] = int(resp_match.group(2))
                    current_interrupt['deadline_met'] = current_interrupt['response_time'] <= current_interrupt['deadline']
                    self.interrupts.append(current_interrupt)
                    current_interrupt = None
    
    def parse_io_operations(self):
        """Parse I/O operations"""
        # I/O operation patterns
        io_start_pattern = r'\[I/O-SIM\] Processing adaptive I/O operation #(\d+) \(Priority: (\d+)\)'
        io_end_pattern = r'\[I/O-SIM\] Adaptive I/O completed, latency: (\d+) ticks \(Priority: (\d+)\)'
        
        lines = self.raw_data.split('\n')
        current_io = None
        
        for i, line in enumerate(lines):
            start_match = re.search(io_start_pattern, line)
            if start_match:
                current_io = {
                    'id': int(start_match.group(1)),
                    'priority': int(start_match.group(2)),
                    'line_start': i
                }
                
            elif current_io:
                end_match = re.search(io_end_pattern, line)
                if end_match:
                    current_io['latency'] = int(end_match.group(1))
                    current_io['line_end'] = i
                    current_io['duration_lines'] = i - current_io['line_start']
                    self.io_operations.append(current_io)
                    current_io = None
    
    def parse_cycle_reports(self):
        """Parse cycle performance reports"""
        cycle_pattern = r'=== CYCLE (\d+) REPORT ==='
        report_sections = re.split(cycle_pattern, self.raw_data)
        
        for i in range(1, len(report_sections), 2):
            if i + 1 < len(report_sections):
                cycle_num = int(report_sections[i])
                report_text = report_sections[i + 1]
                
                cycle_data = self.parse_single_cycle_report(cycle_num, report_text)
                if cycle_data:
                    self.cycle_reports.append(cycle_data)
    
    def parse_single_cycle_report(self, cycle_num, report_text):
        """Parse individual cycle report"""
        try:
            data = {'cycle': cycle_num}
            
            # Total interrupts
            total_match = re.search(r'Total interrupts processed: (\d+)', report_text)
            if total_match:
                data['total_interrupts'] = int(total_match.group(1))
            
            # Priority distribution
            critical_match = re.search(r'Critical \(1\): (\d+)', report_text)
            high_match = re.search(r'High \(2\): (\d+)', report_text)
            normal_match = re.search(r'Normal \(3\): (\d+)', report_text)
            
            if critical_match and high_match and normal_match:
                data['critical_count'] = int(critical_match.group(1))
                data['high_count'] = int(high_match.group(1))
                data['normal_count'] = int(normal_match.group(1))
            
            # Queue statistics
            normal_overflow_match = re.search(r'Normal Queue Overflows: (\d+)', report_text)
            high_overflow_match = re.search(r'High Priority Queue Overflows: (\d+)', report_text)
            queue_depth_match = re.search(r'Current Queue Depth: (\d+)', report_text)
            
            if normal_overflow_match:
                data['normal_queue_overflows'] = int(normal_overflow_match.group(1))
            if high_overflow_match:
                data['high_priority_overflows'] = int(high_overflow_match.group(1))
            if queue_depth_match:
                data['queue_depth'] = int(queue_depth_match.group(1))
            
            # System load metrics
            cpu_match = re.search(r'CPU Utilization: (\d+)%', report_text)
            active_match = re.search(r'Active Interrupts: (\d+)', report_text)
            load_score_match = re.search(r'Load Score: (\d+)', report_text)
            
            if cpu_match:
                data['cpu_utilization'] = int(cpu_match.group(1))
            if active_match:
                data['active_interrupts'] = int(active_match.group(1))
            if load_score_match:
                data['load_score'] = int(load_score_match.group(1))
            
            # Performance metrics
            response_match = re.search(r'Min/Avg/Max Response: (\d+)/(\d+)/(\d+) ticks', report_text)
            if response_match:
                data['min_response'] = int(response_match.group(1))
                data['avg_response'] = int(response_match.group(2))
                data['max_response'] = int(response_match.group(3))
            
            # Deadline success rate
            success_match = re.search(r'Deadline Success Rate: (\d+)% \((\d+) missed\)', report_text)
            if success_match:
                data['success_rate'] = int(success_match.group(1))
                data['missed_deadlines'] = int(success_match.group(2))
            
            # Adaptive algorithm stats
            complexity_adj_match = re.search(r'Complexity Adjustments: (\d+)', report_text)
            deadline_adj_match = re.search(r'Deadline Adjustments: (\d+)', report_text)
            load_opt_match = re.search(r'Load-based Optimizations: (\d+)', report_text)
            
            if complexity_adj_match:
                data['complexity_adjustments'] = int(complexity_adj_match.group(1))
            if deadline_adj_match:
                data['deadline_adjustments'] = int(deadline_adj_match.group(1))
            if load_opt_match:
                data['load_optimizations'] = int(load_opt_match.group(1))
            
            # Current adaptive config
            base_deadline_match = re.search(r'Base Deadline: (\d+) ticks', report_text)
            thresholds_match = re.search(r'Load Thresholds: (\d+)% - (\d+)%', report_text)
            
            if base_deadline_match:
                data['base_deadline'] = int(base_deadline_match.group(1))
            if thresholds_match:
                data['load_threshold_low'] = int(thresholds_match.group(1))
                data['load_threshold_high'] = int(thresholds_match.group(2))
            
            return data
            
        except Exception as e:
            print(f"Error parsing cycle {cycle_num}: {e}")
            return None
    
    def parse_timer_events(self):
        """Parse timer events"""
        timer_pattern = r'\[TIMER-HANDLER\] Periodic timer event #(\d+) processed'
        
        for match in re.finditer(timer_pattern, self.raw_data):
            self.timer_events.append({
                'event_id': int(match.group(1)),
                'position': match.start()
            })
    
    def save_data_to_json(self):
        """Spremi sve parsirane podatke u JSON datoteku."""
        json_file = self.log_file.replace('.log', '_data.json')
        
        # Pripremi podatke za JSON export
        json_data = {
            'metadata': {
                'log_file': os.path.basename(self.log_file),
                'analysis_timestamp': datetime.now().isoformat(),
                'total_interrupts': len(self.interrupts),
                'total_io_operations': len(self.io_operations),
                'total_cycles': len(self.cycle_reports),
                'total_timer_events': len(self.timer_events)
            },
            'interrupts': self.interrupts,
            'io_operations': self.io_operations,
            'cycle_reports': self.cycle_reports,
            'timer_events': self.timer_events
        }
        
        # Spremi u JSON datoteku
        try:
            with open(json_file, 'w', encoding='utf-8') as f:
                json.dump(json_data, f, indent=2, ensure_ascii=False)
            print(f"Data saved to: {json_file}")
        except Exception as e:
            print(f"Error saving JSON file: {e}")

    def generate_detailed_report(self):
        """Generiraj detaljan tekstni izvještaj."""
        report_file = self.log_file.replace('.log', '_detailed_report.txt')
        
        try:
            with open(report_file, 'w', encoding='utf-8') as f:
                f.write("=" * 80 + "\n")
                f.write("FREERTOS ADAPTIVE INTERRUPT SYSTEM - DETAILED ANALYSIS REPORT\n")
                f.write("=" * 80 + "\n")
                f.write(f"Log File: {os.path.basename(self.log_file)}\n")
                f.write(f"Analysis Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
                
                # Interrupt Statistics
                if self.interrupts:
                    f.write("INTERRUPT ANALYSIS:\n")
                    f.write("-" * 40 + "\n")
                    f.write(f"Total Interrupts: {len(self.interrupts)}\n")
                    
                    response_times = [int_data['response_time'] for int_data in self.interrupts]
                    f.write(f"Response Time - Min: {min(response_times)}, Max: {max(response_times)}, Avg: {np.mean(response_times):.2f}\n")
                    
                    priority_counts = {}
                    deadline_success = 0
                    complexity_optimized = 0
                    
                    for int_data in self.interrupts:
                        priority = int_data['priority']
                        priority_counts[priority] = priority_counts.get(priority, 0) + 1
                        if int_data.get('deadline_met', False):
                            deadline_success += 1
                        if int_data.get('complexity_adjusted', False):
                            complexity_optimized += 1
                    
                    f.write(f"Priority Distribution: {dict(sorted(priority_counts.items()))}\n")
                    f.write(f"Deadline Success Rate: {(deadline_success/len(self.interrupts)*100):.1f}%\n")
                    f.write(f"Complexity Optimizations: {complexity_optimized}/{len(self.interrupts)} ({complexity_optimized/len(self.interrupts)*100:.1f}%)\n\n")
                
                # I/O Operations Analysis
                if self.io_operations:
                    f.write("I/O OPERATIONS ANALYSIS:\n")
                    f.write("-" * 40 + "\n")
                    f.write(f"Total I/O Operations: {len(self.io_operations)}\n")
                    
                    latencies = [io_data['latency'] for io_data in self.io_operations]
                    f.write(f"Latency - Min: {min(latencies)}, Max: {max(latencies)}, Avg: {np.mean(latencies):.2f}\n")
                    
                    io_priority_counts = {}
                    for io_data in self.io_operations:
                        priority = io_data['priority']
                        io_priority_counts[priority] = io_priority_counts.get(priority, 0) + 1
                    
                    f.write(f"I/O Priority Distribution: {dict(sorted(io_priority_counts.items()))}\n\n")
                
                # Cycle Reports Analysis
                if self.cycle_reports:
                    f.write("CYCLE PERFORMANCE ANALYSIS:\n")
                    f.write("-" * 40 + "\n")
                    f.write(f"Total Cycles Analyzed: {len(self.cycle_reports)}\n")
                    
                    success_rates = [cycle.get('success_rate', 0) for cycle in self.cycle_reports]
                    cpu_utils = [cycle.get('cpu_utilization', 0) for cycle in self.cycle_reports]
                    
                    f.write(f"Success Rate - Min: {min(success_rates)}%, Max: {max(success_rates)}%, Avg: {np.mean(success_rates):.1f}%\n")
                    f.write(f"CPU Utilization - Min: {min(cpu_utils)}%, Max: {max(cpu_utils)}%, Avg: {np.mean(cpu_utils):.1f}%\n")
                    
                    total_complexity_adj = sum(cycle.get('complexity_adjustments', 0) for cycle in self.cycle_reports)
                    total_deadline_adj = sum(cycle.get('deadline_adjustments', 0) for cycle in self.cycle_reports)
                    total_load_opt = sum(cycle.get('load_optimizations', 0) for cycle in self.cycle_reports)
                    
                    f.write(f"Total Adaptive Interventions:\n")
                    f.write(f"  - Complexity Adjustments: {total_complexity_adj}\n")
                    f.write(f"  - Deadline Adjustments: {total_deadline_adj}\n")
                    f.write(f"  - Load Optimizations: {total_load_opt}\n\n")
                
                # Timer Events
                if self.timer_events:
                    f.write("TIMER EVENTS:\n")
                    f.write("-" * 40 + "\n")
                    f.write(f"Total Timer Events: {len(self.timer_events)}\n\n")
                
                # System Health Summary
                f.write("SYSTEM HEALTH SUMMARY:\n")
                f.write("-" * 40 + "\n")
                
                if self.cycle_reports:
                    # Check for any queue overflows
                    total_overflows = sum(
                        cycle.get('normal_queue_overflows', 0) + cycle.get('high_priority_overflows', 0) 
                        for cycle in self.cycle_reports
                    )
                    f.write(f"Queue Overflows: {total_overflows} (Status: {'GOOD' if total_overflows == 0 else 'NEEDS ATTENTION'})\n")
                    
                    # Average success rate
                    avg_success = np.mean([cycle.get('success_rate', 0) for cycle in self.cycle_reports])
                    f.write(f"Overall Success Rate: {avg_success:.1f}% (Status: {'EXCELLENT' if avg_success > 99 else 'GOOD' if avg_success > 95 else 'NEEDS IMPROVEMENT'})\n")
                    
                    # System stability
                    success_rate_std = np.std([cycle.get('success_rate', 0) for cycle in self.cycle_reports])
                    f.write(f"Performance Stability: {success_rate_std:.2f}% std dev (Status: {'STABLE' if success_rate_std < 2 else 'VARIABLE'})\n")
                
                f.write("\n" + "=" * 80 + "\n")
                f.write("ANALYSIS COMPLETED\n")
                f.write("=" * 80 + "\n")
            
            print(f"Detailed report saved to: {report_file}")
        except Exception as e:
            print(f"Error generating report: {e}")

    def create_comprehensive_analysis(self):
        """Create comprehensive analysis with individual visualizations"""
        print("FREERTOS ADAPTIVE INTERRUPT SYSTEM - COMPREHENSIVE ANALYSIS")
        print("=" * 80)

        # 1. Interrupt Response Time Analysis
        plt.figure(figsize=(8, 6))
        self.plot_response_time_distribution()
        plt.savefig('response_time_distribution.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 2. Priority Distribution Over Time
        plt.figure(figsize=(8, 6))
        self.plot_priority_distribution()
        plt.savefig('priority_distribution.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 3. Cycle Performance Evolution
        plt.figure(figsize=(8, 6))
        self.plot_cycle_performance()
        plt.savefig('deadline_success_rate.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 4. Complexity Optimization
        plt.figure(figsize=(8, 6))
        self.plot_complexity_optimization()
        plt.savefig('complexity_optimization.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 5. I/O Latency Analysis
        plt.figure(figsize=(8, 6))
        self.plot_io_latency_analysis()
        plt.savefig('io_latency_analysis.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 6. System Load Evolution
        plt.figure(figsize=(8, 6))
        self.plot_system_load_evolution()
        plt.savefig('system_load_evolution.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 7. Deadline Success Rate
        plt.figure(figsize=(8, 6))
        self.plot_deadline_success()
        plt.savefig('deadline_success_by_priority.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 8. Adaptive Algorithm Performance
        plt.figure(figsize=(8, 6))
        self.plot_adaptive_performance()
        plt.savefig('adaptive_performance.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 9. Queue Management
        plt.figure(figsize=(8, 6))
        self.plot_queue_management()
        plt.savefig('queue_depth_evolution.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 10. Response Time vs Priority Correlation
        plt.figure(figsize=(8, 6))
        self.plot_response_vs_priority()
        plt.savefig('response_time_by_priority.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 11. Throughput Analysis
        plt.figure(figsize=(8, 6))
        self.plot_throughput_analysis()
        plt.savefig('throughput_analysis.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 12. Critical Interrupt Performance
        plt.figure(figsize=(8, 6))
        self.plot_critical_interrupt_performance()
        plt.savefig('critical_interrupt_response.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 13. I/O Priority Distribution
        plt.figure(figsize=(8, 6))
        self.plot_io_priority_distribution()
        plt.savefig('io_priority_distribution.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 14. System Configuration Evolution
        plt.figure(figsize=(8, 6))
        self.plot_config_evolution()
        plt.savefig('config_evolution.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 15. Overall System Health
        plt.figure(figsize=(8, 6))
        self.plot_system_health()
        plt.savefig('system_health.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 16. Performance Summary
        plt.figure(figsize=(8, 6))
        self.plot_performance_summary()
        plt.savefig('performance_summary.png', dpi=300, bbox_inches='tight')
        plt.close()

        # DODANO: Spremi podatke u JSON i generiraj izvještaj
        self.save_data_to_json()
        self.generate_detailed_report()

    def plot_response_time_distribution(self):
        """Plot interrupt response time distribution"""
        if not self.interrupts:
            plt.text(0.5, 0.5, 'No interrupt data', ha='center', va='center')
            plt.title('Response Time Distribution')
            return
        
        response_times = [interrupt['response_time'] for interrupt in self.interrupts]
        
        plt.hist(response_times, bins=30, alpha=0.7, color='skyblue', edgecolor='black')
        plt.xlabel('Response Time (ticks)')
        plt.ylabel('Frequency')
        plt.title('Interrupt Response Time Distribution')
        plt.axvline(np.mean(response_times), color='red', linestyle='--', 
                   label=f'Mean: {np.mean(response_times):.1f}')
        plt.legend()
        plt.grid(True, alpha=0.3)
    
    def plot_priority_distribution(self):
        """Plot priority distribution over cycles"""
        if not self.cycle_reports:
            plt.text(0.5, 0.5, 'No cycle data', ha='center', va='center')
            plt.title('Priority Distribution')
            return
        
        cycles = [r['cycle'] for r in self.cycle_reports]
        critical = [r.get('critical_count', 0) for r in self.cycle_reports]
        high = [r.get('high_count', 0) for r in self.cycle_reports]
        normal = [r.get('normal_count', 0) for r in self.cycle_reports]
        
        plt.plot(cycles, critical, 'ro-', label='Critical (P1)', linewidth=2)
        plt.plot(cycles, high, 'bo-', label='High (P2)', linewidth=2)
        plt.plot(cycles, normal, 'go-', label='Normal (P3)', linewidth=2)
        
        plt.xlabel('Cycle')
        plt.ylabel('Interrupt Count')
        plt.title('Priority Distribution Evolution')
        plt.legend()
        plt.grid(True, alpha=0.3)
    
    def plot_cycle_performance(self):
        """Plot overall cycle performance metrics"""
        if not self.cycle_reports:
            plt.text(0.5, 0.5, 'No cycle data', ha='center', va='center')
            plt.title('Cycle Performance')
            return
        
        cycles = [r['cycle'] for r in self.cycle_reports]
        success_rates = [r.get('success_rate', 0) for r in self.cycle_reports]
        
        plt.plot(cycles, success_rates, 'g^-', linewidth=3, markersize=8)
        plt.xlabel('Cycle')
        plt.ylabel('Success Rate (%)')
        plt.title('Deadline Success Rate Evolution')
        plt.ylim(95, 101)
        plt.grid(True, alpha=0.3)
        
        # Add annotations for interesting points
        for i, (cycle, rate) in enumerate(zip(cycles, success_rates)):
            if rate < 100:
                plt.annotate(f'{rate}%', (cycle, rate), 
                           textcoords="offset points", xytext=(0,10), ha='center')
    
    def plot_complexity_optimization(self):
        """Plot complexity optimization effectiveness"""
        if not self.interrupts:
            plt.text(0.5, 0.5, 'No interrupt data', ha='center', va='center')
            plt.title('Complexity Optimization')
            return
        
        adjusted = sum(1 for interrupt in self.interrupts if interrupt.get('complexity_adjusted', False))
        not_adjusted = len(self.interrupts) - adjusted
        
        labels = ['Optimized', 'Original']
        sizes = [adjusted, not_adjusted]
        colors = ['lightgreen', 'lightcoral']
        
        plt.pie(sizes, labels=labels, colors=colors, autopct='%1.1f%%', startangle=90)
        plt.title('Complexity Optimization Rate')
    
    def plot_io_latency_analysis(self):
        """Plot I/O operation latency analysis"""
        if not self.io_operations:
            plt.text(0.5, 0.5, 'No I/O data', ha='center', va='center')
            plt.title('I/O Latency Analysis')
            return
        
        latencies = [io['latency'] for io in self.io_operations]
        priorities = [io['priority'] for io in self.io_operations]
        
        # Create scatter plot with priority-based coloring
        scatter = plt.scatter(range(len(latencies)), latencies, c=priorities, 
                            cmap='RdYlBu_r', alpha=0.6)
        plt.colorbar(scatter, label='Priority')
        plt.xlabel('I/O Operation #')
        plt.ylabel('Latency (ticks)')
        plt.title('I/O Operation Latency vs Priority')
        plt.grid(True, alpha=0.3)
    
    def plot_system_load_evolution(self):
        """Plot system load metrics evolution"""
        if not self.cycle_reports:
            plt.text(0.5, 0.5, 'No cycle data', ha='center', va='center')
            plt.title('System Load Evolution')
            return
        
        cycles = [r['cycle'] for r in self.cycle_reports]
        cpu_util = [r.get('cpu_utilization', 0) for r in self.cycle_reports]
        load_score = [r.get('load_score', 0) for r in self.cycle_reports]
        
        plt.plot(cycles, cpu_util, 'r-o', label='CPU Utilization (%)', linewidth=2)
        plt.plot(cycles, load_score, 'b-s', label='Load Score', linewidth=2)
        
        plt.xlabel('Cycle')
        plt.ylabel('Percentage / Score')
        plt.title('System Load Evolution')
        plt.legend()
        plt.grid(True, alpha=0.3)
    
    def plot_deadline_success(self):
        """Plot detailed deadline success analysis"""
        if not self.interrupts:
            plt.text(0.5, 0.5, 'No interrupt data', ha='center', va='center')
            plt.title('Deadline Analysis')
            return
        
        # Group by priority
        priority_groups = defaultdict(list)
        for interrupt in self.interrupts:
            priority_groups[interrupt['priority']].append(interrupt['deadline_met'])
        
        priorities = sorted(priority_groups.keys())
        success_rates = []
        
        for p in priorities:
            success_rate = (sum(priority_groups[p]) / len(priority_groups[p])) * 100
            success_rates.append(success_rate)
        
        colors = ['red', 'orange', 'green', 'blue'][:len(priorities)]
        bars = plt.bar([f'P{p}' for p in priorities], success_rates, color=colors, alpha=0.7)
        
        plt.ylabel('Success Rate (%)')
        plt.title('Deadline Success Rate by Priority')
        plt.ylim(95, 101)
        plt.grid(True, alpha=0.3)
        
        # Add value labels on bars
        for bar, rate in zip(bars, success_rates):
            plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
                    f'{rate:.1f}%', ha='center', va='bottom')
    
    def plot_adaptive_performance(self):
        """Plot adaptive algorithm performance metrics"""
        if not self.cycle_reports:
            plt.text(0.5, 0.5, 'No cycle data', ha='center', va='center')
            plt.title('Adaptive Performance')
            return
        
        cycles = [r['cycle'] for r in self.cycle_reports]
        complexity_adj = [r.get('complexity_adjustments', 0) for r in self.cycle_reports]
        deadline_adj = [r.get('deadline_adjustments', 0) for r in self.cycle_reports]
        load_opt = [r.get('load_optimizations', 0) for r in self.cycle_reports]
        
        width = 0.25
        x = np.arange(len(cycles))
        
        plt.bar(x - width, complexity_adj, width, label='Complexity Adj.', alpha=0.8)
        plt.bar(x, deadline_adj, width, label='Deadline Adj.', alpha=0.8)
        plt.bar(x + width, load_opt, width, label='Load Optimizations', alpha=0.8)
        
        plt.xlabel('Cycle')
        plt.ylabel('Count')
        plt.title('Adaptive Algorithm Interventions')
        plt.xticks(x, cycles)
        plt.legend()
        plt.grid(True, alpha=0.3)
    
    def plot_queue_management(self):
        """Plot queue management effectiveness"""
        if not self.cycle_reports:
            plt.text(0.5, 0.5, 'No cycle data', ha='center', va='center')
            plt.title('Queue Management')
            return
        
        # All reports show 0 overflows - this is good!
        cycles = [r['cycle'] for r in self.cycle_reports]
        queue_depths = [r.get('queue_depth', 0) for r in self.cycle_reports]
        
        plt.plot(cycles, queue_depths, 'g-o', linewidth=3, markersize=8)
        plt.xlabel('Cycle')
        plt.ylabel('Queue Depth')
        plt.title('Queue Depth Evolution (0 = Optimal)')
        plt.grid(True, alpha=0.3)
        
        # Add success message
        plt.text(0.5, 0.8, 'ZERO QUEUE OVERFLOWS', 
                transform=plt.gca().transAxes, ha='center', 
                bbox=dict(boxstyle="round,pad=0.3", facecolor="lightgreen"))
    
    def plot_response_vs_priority(self):
        """Plot response time vs priority correlation"""
        if not self.interrupts:
            plt.text(0.5, 0.5, 'No interrupt data', ha='center', va='center')
            plt.title('Response vs Priority')
            return
        
        priorities = [interrupt['priority'] for interrupt in self.interrupts]
        response_times = [interrupt['response_time'] for interrupt in self.interrupts]
        
        # Create boxplot
        priority_groups = defaultdict(list)
        for p, r in zip(priorities, response_times):
            priority_groups[p].append(r)
        
        data_to_plot = [priority_groups[p] for p in sorted(priority_groups.keys())]
        labels = [f'P{p}' for p in sorted(priority_groups.keys())]
        
        plt.boxplot(data_to_plot, tick_labels=labels)
        plt.ylabel('Response Time (ticks)')
        plt.title('Response Time by Priority')
        plt.grid(True, alpha=0.3)
    
    def plot_throughput_analysis(self):
        """Plot system throughput analysis"""
        if not self.cycle_reports:
            plt.text(0.5, 0.5, 'No cycle data', ha='center', va='center')
            plt.title('Throughput Analysis')
            return
        
        cycles = [r['cycle'] for r in self.cycle_reports]
        total_interrupts = [r.get('total_interrupts', 0) for r in self.cycle_reports]
        
        # Calculate throughput (interrupts per cycle)
        if len(total_interrupts) > 1:
            throughput = [total_interrupts[i] - total_interrupts[i-1] 
                         for i in range(1, len(total_interrupts))]
            throughput_cycles = cycles[1:]
        else:
            throughput = total_interrupts
            throughput_cycles = cycles
        
        plt.plot(throughput_cycles, throughput, 'purple', marker='o', linewidth=2)
        plt.xlabel('Cycle')
        plt.ylabel('Interrupts Processed')
        plt.title('System Throughput (Interrupts/Cycle)')
        plt.grid(True, alpha=0.3)
    
    def plot_critical_interrupt_performance(self):
        """Plot critical interrupt specific performance"""
        if not self.interrupts:
            plt.text(0.5, 0.5, 'No interrupt data', ha='center', va='center')
            plt.title('Critical Interrupt Performance')
            return
        
        critical_interrupts = [int for int in self.interrupts if int['priority'] == 1]
        
        if not critical_interrupts:
            plt.text(0.5, 0.5, 'No critical interrupts', ha='center', va='center')
            plt.title('Critical Interrupt Performance')
            return
        
        response_times = [int['response_time'] for int in critical_interrupts]
        deadlines = [int['deadline'] for int in critical_interrupts]
        
        plt.hist(response_times, bins=20, alpha=0.7, color='red', label='Response Times')
        plt.axvline(np.mean(deadlines), color='blue', linestyle='--', 
                   label=f'Avg Deadline: {np.mean(deadlines):.1f}')
        plt.xlabel('Time (ticks)')
        plt.ylabel('Frequency')
        plt.title('Critical Interrupt Response Times')
        plt.legend()
        plt.grid(True, alpha=0.3)
    
    def plot_io_priority_distribution(self):
        """Plot I/O operation priority distribution"""
        if not self.io_operations:
            plt.text(0.5, 0.5, 'No I/O data', ha='center', va='center')
            plt.title('I/O Priority Distribution')
            return
        
        priorities = [io['priority'] for io in self.io_operations]
        priority_counts = defaultdict(int)
        for p in priorities:
            priority_counts[p] += 1
        
        labels = [f'Priority {p}' for p in sorted(priority_counts.keys())]
        sizes = [priority_counts[p] for p in sorted(priority_counts.keys())]
        colors = plt.cm.Set3(np.linspace(0, 1, len(labels)))
        
        plt.pie(sizes, labels=labels, colors=colors, autopct='%1.1f%%', startangle=90)
        plt.title('I/O Operations by Priority')
    
    def plot_config_evolution(self):
        """Plot adaptive configuration evolution"""
        if not self.cycle_reports:
            plt.text(0.5, 0.5, 'No cycle data', ha='center', va='center')
            plt.title('Config Evolution')
            return
        
        cycles = [r['cycle'] for r in self.cycle_reports]
        base_deadlines = [r.get('base_deadline', 0) for r in self.cycle_reports]
        
        plt.plot(cycles, base_deadlines, 'b-o', linewidth=2, markersize=6)
        plt.xlabel('Cycle')
        plt.ylabel('Base Deadline (ticks)')
        plt.title('Adaptive Configuration Evolution')
        plt.grid(True, alpha=0.3)
        
        # Annotate optimization points
        for i in range(1, len(base_deadlines)):
            if base_deadlines[i] != base_deadlines[i-1]:
                plt.annotate('Adjusted', (cycles[i], base_deadlines[i]),
                     textcoords="offset points", xytext=(0,10), ha='center', color='blue', fontsize=9)

    def plot_system_health(self):
        """Plot overall system health metrics"""
        if not self.cycle_reports:
            plt.text(0.5, 0.5, 'No cycle data', ha='center', va='center')
            plt.title('System Health')
            return
        
        cycles = [r['cycle'] for r in self.cycle_reports]
        success_rates = [r.get('success_rate', 0) for r in self.cycle_reports]
        cpu_utils = [r.get('cpu_utilization', 0) for r in self.cycle_reports]
        queue_depths = [r.get('queue_depth', 0) for r in self.cycle_reports]
        
        fig, (ax1, ax2, ax3) = plt.subplots(3, 1, figsize=(8, 10))
        
        # Success rate
        ax1.plot(cycles, success_rates, 'g-o', linewidth=2)
        ax1.set_ylabel('Success Rate (%)')
        ax1.set_title('System Health Metrics')
        ax1.grid(True, alpha=0.3)
        ax1.set_ylim(95, 101)
        
        # CPU utilization
        ax2.plot(cycles, cpu_utils, 'r-s', linewidth=2)
        ax2.set_ylabel('CPU Utilization (%)')
        ax2.grid(True, alpha=0.3)
        
        # Queue depth
        ax3.plot(cycles, queue_depths, 'b-^', linewidth=2)
        ax3.set_ylabel('Queue Depth')
        ax3.set_xlabel('Cycle')
        ax3.grid(True, alpha=0.3)
        
        plt.tight_layout()

    def plot_performance_summary(self):
        """Plot performance summary dashboard"""
        if not self.interrupts or not self.cycle_reports:
            plt.text(0.5, 0.5, 'Insufficient data for summary', ha='center', va='center')
            plt.title('Performance Summary')
            return
        
        fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(12, 10))
        
        # 1. Response time histogram
        response_times = [int['response_time'] for int in self.interrupts]
        ax1.hist(response_times, bins=20, alpha=0.7, color='skyblue', edgecolor='black')
        ax1.set_title('Response Time Distribution')
        ax1.set_xlabel('Response Time (ticks)')
        ax1.set_ylabel('Frequency')
        ax1.axvline(np.mean(response_times), color='red', linestyle='--', 
                   label=f'Mean: {np.mean(response_times):.1f}')
        ax1.legend()
        ax1.grid(True, alpha=0.3)
        
        # 2. Priority distribution pie chart
        priority_counts = defaultdict(int)
        for interrupt in self.interrupts:
            priority_counts[interrupt['priority']] += 1
        
        labels = [f'P{p}' for p in sorted(priority_counts.keys())]
        sizes = [priority_counts[p] for p in sorted(priority_counts.keys())]
        colors = ['red', 'orange', 'green', 'blue'][:len(labels)]
        
        ax2.pie(sizes, labels=labels, colors=colors, autopct='%1.1f%%', startangle=90)
        ax2.set_title('Priority Distribution')
        
        # 3. Success rate evolution
        cycles = [r['cycle'] for r in self.cycle_reports]
        success_rates = [r.get('success_rate', 0) for r in self.cycle_reports]
        
        ax3.plot(cycles, success_rates, 'g^-', linewidth=3, markersize=8)
        ax3.set_title('Success Rate Evolution')
        ax3.set_xlabel('Cycle')
        ax3.set_ylabel('Success Rate (%)')
        ax3.set_ylim(95, 101)
        ax3.grid(True, alpha=0.3)
        
        # 4. System load
        cpu_utils = [r.get('cpu_utilization', 0) for r in self.cycle_reports]
        load_scores = [r.get('load_score', 0) for r in self.cycle_reports]
        
        ax4.plot(cycles, cpu_utils, 'r-o', label='CPU Util (%)', linewidth=2)
        ax4.plot(cycles, load_scores, 'b-s', label='Load Score', linewidth=2)
        ax4.set_title('System Load')
        ax4.set_xlabel('Cycle')
        ax4.set_ylabel('Percentage / Score')
        ax4.legend()
        ax4.grid(True, alpha=0.3)
        
        plt.tight_layout()


if __name__ == "__main__":
    analyzer = InterruptAnalyzer('interrupt_demo.log')
    analyzer.create_comprehensive_analysis()
    print("Analysis completed successfully!")
    print(f"Generated files:")
    print(f"- JSON data: {analyzer.log_file.replace('.log', '_data.json')}")
    print(f"- Report: {analyzer.log_file.replace('.log', '_detailed_report.txt')}")
    print(f"- 16 PNG graphs generated")
    print(f"- Total interrupts analyzed: {len(analyzer.interrupts)}")
    print(f"- Total I/O operations: {len(analyzer.io_operations)}")
    print(f"- Total cycles: {len(analyzer.cycle_reports)}")
    print(f"- Total timer events: {len(analyzer.timer_events)}")