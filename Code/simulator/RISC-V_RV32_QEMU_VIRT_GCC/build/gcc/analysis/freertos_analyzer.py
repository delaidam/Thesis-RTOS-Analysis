import re
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
import glob
from scipy import stats
from datetime import datetime

class FreeRTOSAnalyzer:
    def __init__(self, data_dir="data/"):
        self.data_dir = Path(data_dir)
        self.results = {}
        
    def parse_sync_log(self, content):
        """Parse synchronization test log"""
        data = {}
        
        # Parse semaphore give
        match = re.search(r'BINARY SEMAPHORE GIVE CYCLES:\s+Min: (\d+) cycles\s+Max: (\d+) cycles\s+Avg: (\d+) cycles', content)
        if match:
            data['semaphore_give'] = {
                'min': int(match.group(1)),
                'max': int(match.group(2)),
                'avg': int(match.group(3))
            }
        
        # Parse semaphore take
        match = re.search(r'BINARY SEMAPHORE TAKE CYCLES:\s+Min: (\d+) cycles\s+Max: (\d+) cycles\s+Avg: (\d+) cycles', content)
        if match:
            data['semaphore_take'] = {
                'min': int(match.group(1)),
                'max': int(match.group(2)),
                'avg': int(match.group(3))
            }
        
        # Parse mutex give
        match = re.search(r'MUTEX GIVE CYCLES:\s+Min: (\d+) cycles\s+Max: (\d+) cycles\s+Avg: (\d+) cycles', content)
        if match:
            data['mutex_give'] = {
                'min': int(match.group(1)),
                'max': int(match.group(2)),
                'avg': int(match.group(3))
            }
        
        # Parse mutex take
        match = re.search(r'MUTEX TAKE CYCLES:\s+Min: (\d+) cycles\s+Max: (\d+) cycles\s+Avg: (\d+) cycles', content)
        if match:
            data['mutex_take'] = {
                'min': int(match.group(1)),
                'max': int(match.group(2)),
                'avg': int(match.group(3))
            }
        
        return data
    
    def parse_memory_log(self, content):
        """Parse memory allocation test log"""
        data = {}
        
        # Parse small allocation malloc
        match = re.search(r'SMALL ALLOCATION.*?MALLOC CYCLES.*?Min: (\d+) cycles\s+Max: (\d+) cycles\s+Avg: (\d+) cycles', content, re.DOTALL)
        if match:
            data['small_malloc'] = {
                'min': int(match.group(1)),
                'max': int(match.group(2)),
                'avg': int(match.group(3))
            }
        
        # Parse small allocation free
        match = re.search(r'SMALL ALLOCATION.*?FREE CYCLES.*?Min: (\d+) cycles\s+Max: (\d+) cycles\s+Avg: (\d+) cycles', content, re.DOTALL)
        if match:
            data['small_free'] = {
                'min': int(match.group(1)),
                'max': int(match.group(2)),
                'avg': int(match.group(3))
            }
        
        # Parse medium allocation malloc
        match = re.search(r'MEDIUM ALLOCATION.*?MALLOC CYCLES.*?Min: (\d+) cycles\s+Max: (\d+) cycles\s+Avg: (\d+) cycles', content, re.DOTALL)
        if match:
            data['medium_malloc'] = {
                'min': int(match.group(1)),
                'max': int(match.group(2)),
                'avg': int(match.group(3))
            }
        
        # Parse medium allocation free
        match = re.search(r'MEDIUM ALLOCATION.*?FREE CYCLES.*?Min: (\d+) cycles\s+Max: (\d+) cycles\s+Avg: (\d+) cycles', content, re.DOTALL)
        if match:
            data['medium_free'] = {
                'min': int(match.group(1)),
                'max': int(match.group(2)),
                'avg': int(match.group(3))
            }
        
        return data
    
    def parse_context_log(self, content):
        """Parse context switch test log"""
        data = {}
        
        # Parse context switch latencies
        match = re.search(r'CONTEXT SWITCH.*?Min: (\d+) cycles\s+Max: (\d+) cycles\s+Avg: (\d+) cycles', content, re.DOTALL)
        if match:
            data['context_switch'] = {
                'min': int(match.group(1)),
                'max': int(match.group(2)),
                'avg': int(match.group(3))
            }
        
        # Parse task creation/deletion if present
        match = re.search(r'TASK CREATION.*?Min: (\d+) cycles\s+Max: (\d+) cycles\s+Avg: (\d+) cycles', content, re.DOTALL)
        if match:
            data['task_creation'] = {
                'min': int(match.group(1)),
                'max': int(match.group(2)),
                'avg': int(match.group(3))
            }
        
        match = re.search(r'TASK DELETION.*?Min: (\d+) cycles\s+Max: (\d+) cycles\s+Avg: (\d+) cycles', content, re.DOTALL)
        if match:
            data['task_deletion'] = {
                'min': int(match.group(1)),
                'max': int(match.group(2)),
                'avg': int(match.group(3))
            }
        
        return data
    
    def parse_interrupt_log(self, content):
        """Parse interrupt latency test log"""
        data = {}
        
        # Parse interrupt response time
        match = re.search(r'INTERRUPT RESPONSE.*?Min: (\d+) cycles\s+Max: (\d+) cycles\s+Avg: (\d+) cycles', content, re.DOTALL)
        if match:
            data['interrupt_response'] = {
                'min': int(match.group(1)),
                'max': int(match.group(2)),
                'avg': int(match.group(3))
            }
        
        # Parse interrupt latency
        match = re.search(r'INTERRUPT LATENCY.*?Min: (\d+) cycles\s+Max: (\d+) cycles\s+Avg: (\d+) cycles', content, re.DOTALL)
        if match:
            data['interrupt_latency'] = {
                'min': int(match.group(1)),
                'max': int(match.group(2)),
                'avg': int(match.group(3))
            }
        
        return data
    
    def parse_queue_log(self, content):
        """Parse queue performance test log"""
        data = {}
        
        # Parse queue send
        match = re.search(r'QUEUE SEND.*?Min: (\d+) cycles\s+Max: (\d+) cycles\s+Avg: (\d+) cycles', content, re.DOTALL)
        if match:
            data['queue_send'] = {
                'min': int(match.group(1)),
                'max': int(match.group(2)),
                'avg': int(match.group(3))
            }
        
        # Parse queue receive
        match = re.search(r'QUEUE RECEIVE.*?Min: (\d+) cycles\s+Max: (\d+) cycles\s+Avg: (\d+) cycles', content, re.DOTALL)
        if match:
            data['queue_receive'] = {
                'min': int(match.group(1)),
                'max': int(match.group(2)),
                'avg': int(match.group(3))
            }
        
        return data
    
    def load_data(self):
        """Load all log files and extract data"""
        log_files = list(self.data_dir.glob("*.log"))
        
        if not log_files:
            print(f"No log files found in {self.data_dir}")
            print("Run 'make collect-quick-data' first!")
            return
        
        for log_file in log_files:
            try:
                with open(log_file, 'r') as f:
                    content = f.read()
                
                # Determine test type from filename
                filename = log_file.name
                if 'sync' in filename:
                    test_type = 'synchronization'
                    parsed_data = self.parse_sync_log(content)
                elif 'memory' in filename:
                    test_type = 'memory'
                    parsed_data = self.parse_memory_log(content)
                elif 'context' in filename:
                    test_type = 'context'
                    parsed_data = self.parse_context_log(content)
                elif 'ipc' in filename:
                    test_type = 'ipc'
                    parsed_data = self.parse_sync_log(content)  # IPC uses similar format to sync
                elif 'interrupt' in filename:
                    test_type = 'interrupt'
                    parsed_data = self.parse_interrupt_log(content)
                elif 'queue' in filename:
                    test_type = 'queue'
                    parsed_data = self.parse_queue_log(content)
                else:
                    continue
                
                if parsed_data:
                    if test_type not in self.results:
                        self.results[test_type] = []
                    self.results[test_type].append(parsed_data)
                    
            except Exception as e:
                print(f"Error parsing {log_file}: {e}")
        
        print(f"Loaded data from {len(log_files)} files:")
        for test_type, data in self.results.items():
            print(f"  {test_type}: {len(data)} runs")
    
    def calculate_statistics(self):
        """Calculate comprehensive statistics"""
        stats_results = {}
        
        for test_type, runs in self.results.items():
            stats_results[test_type] = {}
            
            # Get all operation types from first run
            if runs:
                operations = runs[0].keys()
                
                for op in operations:
                    # Collect all values for this operation
                    avgs = []
                    mins = []
                    maxs = []
                    
                    for run in runs:
                        if op in run:
                            avgs.append(run[op]['avg'])
                            mins.append(run[op]['min'])
                            maxs.append(run[op]['max'])
                    
                    if avgs:  # If we have data
                        stats_results[test_type][op] = {
                            'mean_avg': np.mean(avgs),
                            'std_avg': np.std(avgs),
                            'min_observed': min(mins),
                            'max_observed': max(maxs),
                            'avg_jitter': np.mean([mx/mn for mx, mn in zip(maxs, mins)]),
                            'wcet_95': np.percentile(maxs, 95),
                            'wcet_99': np.percentile(maxs, 99),
                            'coefficient_variation': np.std(avgs) / np.mean(avgs) if np.mean(avgs) > 0 else 0
                        }
        
        return stats_results
    
    def plot_results(self):
        """Create visualization plots"""
        if not self.results:
            print("No data to plot. Run load_data() first!")
            return
        
        # Set style
        plt.style.use('default')
        sns.set_palette("husl")
        
        # Create subplots
        n_tests = len(self.results)
        fig, axes = plt.subplots(2, 2, figsize=(15, 12))
        fig.suptitle('FreeRTOS Performance Analysis on RISC-V', fontsize=16, fontweight='bold')
        
        # Plot 1: Average latencies comparison
        ax1 = axes[0, 0]
        all_ops = []
        all_latencies = []
        all_tests = []
        
        for test_type, runs in self.results.items():
            if runs:
                for op in runs[0].keys():
                    avgs = [run[op]['avg'] for run in runs if op in run]
                    if avgs:
                        all_ops.append(f"{op.replace('_', ' ').title()}")
                        all_latencies.append(np.mean(avgs))
                        all_tests.append(test_type.title())
        
        if all_ops:
            df_latency = pd.DataFrame({
                'Operation': all_ops,
                'Avg Cycles': all_latencies,
                'Test Type': all_tests
            })
            
            sns.barplot(data=df_latency, x='Operation', y='Avg Cycles', hue='Test Type', ax=ax1)
            ax1.set_title('Average Operation Latencies')
            ax1.tick_params(axis='x', rotation=45)
            ax1.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
        
        # Plot 2: Jitter analysis
        ax2 = axes[0, 1]
        jitter_ops = []
        jitter_ratios = []
        
        for test_type, runs in self.results.items():
            if runs:
                for op in runs[0].keys():
                    maxs = [run[op]['max'] for run in runs if op in run]
                    mins = [run[op]['min'] for run in runs if op in run]
                    if maxs and mins:
                        jitter_ops.append(f"{op.replace('_', ' ').title()}")
                        jitter_ratios.append(np.mean([mx/mn for mx, mn in zip(maxs, mins)]))
        
        if jitter_ops:
            df_jitter = pd.DataFrame({
                'Operation': jitter_ops,
                'Jitter Ratio': jitter_ratios
            })
            
            sns.barplot(data=df_jitter, x='Operation', y='Jitter Ratio', ax=ax2)
            ax2.set_title('Jitter Analysis (Max/Min Ratio)')
            ax2.tick_params(axis='x', rotation=45)
        
        # Plot 3: WCET distribution for sync operations
        ax3 = axes[1, 0]
        if 'synchronization' in self.results:
            wcet_data = []
            for op in ['semaphore_give', 'semaphore_take', 'mutex_give', 'mutex_take']:
                maxs = []
                for run in self.results['synchronization']:
                    if op in run:
                        maxs.append(run[op]['max'])
                if maxs:
                    for max_val in maxs:
                        wcet_data.append({
                            'Operation': op.replace('_', ' ').title(),
                            'WCET (cycles)': max_val
                        })
            
            if wcet_data:
                df_wcet = pd.DataFrame(wcet_data)
                sns.boxplot(data=df_wcet, x='Operation', y='WCET (cycles)', ax=ax3)
                ax3.set_title('WCET Distribution - Synchronization')
                ax3.tick_params(axis='x', rotation=45)
        
        # Plot 4: Memory allocation efficiency
        ax4 = axes[1, 1]
        if 'memory' in self.results:
            memory_eff_data = []
            for run in self.results['memory']:
                if 'small_malloc' in run and 'small_free' in run:
                    memory_eff_data.extend([
                        {'Size': 'Small (32B)', 'Operation': 'Malloc', 'Cycles': run['small_malloc']['avg']},
                        {'Size': 'Small (32B)', 'Operation': 'Free', 'Cycles': run['small_free']['avg']}
                    ])
                if 'medium_malloc' in run and 'medium_free' in run:
                    memory_eff_data.extend([
                        {'Size': 'Medium (128B)', 'Operation': 'Malloc', 'Cycles': run['medium_malloc']['avg']},
                        {'Size': 'Medium (128B)', 'Operation': 'Free', 'Cycles': run['medium_free']['avg']}
                    ])
            
            if memory_eff_data:
                df_memory = pd.DataFrame(memory_eff_data)
                sns.barplot(data=df_memory, x='Size', y='Cycles', hue='Operation', ax=ax4)
                ax4.set_title('Memory Allocation Efficiency')
        
        plt.tight_layout()
        plt.savefig('freertos_performance_analysis.png', dpi=300, bbox_inches='tight')
        plt.show()
        print("Plot saved as 'freertos_performance_analysis.png'")
    
    def generate_report(self):
        """Generate comprehensive analysis report"""
        if not self.results:
            print("No data to analyze. Run load_data() first!")
            return
        
        stats = self.calculate_statistics()
        
        report = []
        report.append("FreeRTOS Performance Analysis Report")
        report.append("=" * 50)
        report.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append(f"Platform: RISC-V (QEMU emulation)")
        report.append("")
        
        for test_type, operations in stats.items():
            report.append(f"{test_type.upper()} TEST RESULTS")
            report.append("-" * 40)
            
            for op, metrics in operations.items():
                report.append(f"\n{op.replace('_', ' ').title()}:")
                report.append(f"  Average: {metrics['mean_avg']:.1f} ± {metrics['std_avg']:.1f} cycles")
                report.append(f"  Min observed: {metrics['min_observed']} cycles")
                report.append(f"  Max observed: {metrics['max_observed']} cycles")
                report.append(f"  WCET (95%): {metrics['wcet_95']:.1f} cycles")
                report.append(f"  WCET (99%): {metrics['wcet_99']:.1f} cycles")
                report.append(f"  Jitter ratio: {metrics['avg_jitter']:.1f}x")
                report.append(f"  Coefficient of variation: {metrics['coefficient_variation']:.3f}")
                
                # Convert to time (assuming 25 MHz)
                time_us = metrics['mean_avg'] / 25
                wcet_us = metrics['wcet_95'] / 25
                report.append(f"  Time estimates (25 MHz): {time_us:.1f} µs avg, {wcet_us:.1f} µs WCET")
            
            report.append("")
        
        # Save report
        with open('performance_report.txt', 'w') as f:
            f.write('\n'.join(report))
        
        print("Report saved as 'performance_report.txt'")
        
        # Print summary to console
        print("\n" + "\n".join(report))

# Main execution
if __name__ == "__main__":
    print("FreeRTOS Performance Analyzer")
    print("=" * 40)
    
    # Create analyzer
    analyzer = FreeRTOSAnalyzer()
    
    # Load data
    print("Loading data...")
    analyzer.load_data()
    
    if analyzer.results:
        # Generate plots
        print("\nGenerating plots...")
        analyzer.plot_results()
        
        # Generate report
        print("\nGenerating report...")
        analyzer.generate_report()
        
        print("\nAnalysis completed!")
        print("Files generated:")
        print("  - freertos_performance_analysis.png")
        print("  - performance_report.txt")
    else:
        print("\nNo data found!")
        print("Run 'make collect-quick-data' first to collect test data.")