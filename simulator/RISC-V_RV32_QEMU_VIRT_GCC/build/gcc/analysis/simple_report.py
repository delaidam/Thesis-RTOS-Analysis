from freertos_analyzer import FreeRTOSAnalyzer

print('FreeRTOS Performance Report Generator')
print('=====================================')

# Create analyzer
analyzer = FreeRTOSAnalyzer()

# Load data
print('Loading data...')
analyzer.load_data()

# Generate report only (no plots)
print('Generating report...')
analyzer.generate_report()

print('Report generated: performance_report.txt')
print('Done!')
