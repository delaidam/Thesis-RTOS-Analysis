import re
import os
import json
import argparse
from datetime import datetime
import matplotlib.pyplot as plt

def parse_queue_log(log_file):
    """Parsira log datoteku i ekstrahira podatke o porukama i latenciji po prioritetu."""
    data = {"CRITICAL": [], "HIGH": [], "NORMAL": [], "LOW": []}
    total_cycles = 0
    try:
        with open(log_file, 'r') as f:
            content = f.read()
            total_cycles_match = re.search(r"Demo completed after (\d+) cycles", content)
            total_cycles = int(total_cycles_match.group(1)) if total_cycles_match else 501  # Pretpostavi 501 ako nije pronađeno
            reports = re.findall(r"=== ADVANCED QUEUE PERFORMANCE ANALYSIS ===.*?=== SYSTEM PERFORMANCE SUMMARY ===", content, re.DOTALL)
            if not reports:
                print(f"Nema izvješća u {log_file}. Provjeri log.")
                return data, total_cycles
            for i, report in enumerate(reports):
                for priority in data.keys():
                    sent_match = re.search(rf"{priority} Priority Queue:\s*.*?Messages sent: (\d+)", report, re.DOTALL)
                    received_match = re.search(rf"{priority} Priority Queue:\s*.*?Messages received: (\d+)", report, re.DOTALL)
                    avg_latency_match = re.search(rf"{priority} Priority Queue:\s*.*?Avg latency: (\d+)", report, re.DOTALL)
                    if sent_match and received_match and avg_latency_match:
                        data[priority].append({
                            "sent": int(sent_match.group(1)),
                            "received": int(received_match.group(1)),
                            "avg_latency": int(avg_latency_match.group(1)) if avg_latency_match.group(1) else 0
                        })
                    elif sent_match and received_match:
                        data[priority].append({
                            "sent": int(sent_match.group(1)),
                            "received": int(received_match.group(1)),
                            "avg_latency": 0
                        })
    except FileNotFoundError:
        print(f"Datoteka {log_file} nije pronađena.")
    except Exception as e:
        print(f"Greška pri parsiranju {log_file}: {e}")
    return data, total_cycles

def save_data_to_json(log_file, data, total_cycles=0):
    """Sprema parsirane podatke u JSON datoteku s dodatnim statistikama i throughputom."""
    json_data = {
        "log_file": os.path.basename(log_file),
        "timestamp": datetime.now().strftime("%Y-%m-%d %I:%M %p %Z"),
        "data": data
    }
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
            "throughput": (sum(received) / (total_cycles / 1000)) if (total_cycles and total_cycles > 0) else 0  # Pretpostavi 1000 Hz
        }
    json_data["stats"] = stats

    json_file = os.path.join(os.path.dirname(log_file), f'{os.path.basename(log_file)}_data.json')
    with open(json_file, 'w') as f:
        json.dump(json_data, f, indent=4)
    print(f"Data saved to {json_file}")

def generate_graphs(log_file, data, total_cycles):
    """Generate separate figures for each metric with English titles and a summary table."""
    import matplotlib.pyplot as plt
    import json

    # Prepare x-axis
    report_count = len(next(iter(data.values())))
    x_axis = [i * (total_cycles / (report_count - 1)) if report_count > 1 else i for i in range(report_count)]

    # Figure 1: Messages Sent
    plt.figure()
    for priority in data.keys():
        sent = [d["sent"] for d in data[priority]]
        plt.plot(x_axis, sent, label=priority, marker='o', linewidth=2)
    plt.title('Messages Sent Over Time (Cycles)')
    plt.xlabel('Cycles')
    plt.ylabel('Messages Sent')
    plt.legend()
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.savefig('messages_sent.png', dpi=300, bbox_inches='tight')
    plt.close()

    # Figure 2: Messages Received
    plt.figure()
    for priority in data.keys():
        received = [d["received"] for d in data[priority]]
        plt.plot(x_axis, received, label=priority, marker='o', linewidth=2)
    plt.title('Messages Received Over Time (Cycles)')
    plt.xlabel('Cycles')
    plt.ylabel('Messages Received')
    plt.legend()
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.savefig('messages_received.png', dpi=300, bbox_inches='tight')
    plt.close()

    # Figure 3: Average Latency
    plt.figure()
    for priority in data.keys():
        latency = [d["avg_latency"] for d in data[priority]]
        plt.plot(x_axis, latency, label=priority, marker='o', linewidth=2)
    plt.title('Average Latency Over Time (Cycles)')
    plt.xlabel('Cycles')
    plt.ylabel('Average Latency (ticks)')
    plt.legend()
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.savefig('average_latency.png', dpi=300, bbox_inches='tight')
    plt.close()

    # Figure 4: Performance Summary Table
    # Load stats from JSON file if available, otherwise calculate here
    stats = {}
    json_file = os.path.join(os.path.dirname(log_file), f'{os.path.basename(log_file)}_data.json')
    if os.path.exists(json_file):
        with open(json_file, 'r') as f:
            stats = json.load(f)["stats"]
    else:
        # Fallback: calculate stats here if not already done
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

    plt.figure()
    fig, ax = plt.subplots()
    ax.axis('off')
    table_data = [
        ["Priority", "Total Sent", "Total Received", "Avg Latency", "Throughput"],
        ["CRITICAL", stats["CRITICAL"]["total_sent"], stats["CRITICAL"]["total_received"], f'{stats["CRITICAL"]["avg_latency"]:.2f}', f'{stats["CRITICAL"]["throughput"]:.2f}'],
        ["HIGH", stats["HIGH"]["total_sent"], stats["HIGH"]["total_received"], f'{stats["HIGH"]["avg_latency"]:.2f}', f'{stats["HIGH"]["throughput"]:.2f}'],
        ["NORMAL", stats["NORMAL"]["total_sent"], stats["NORMAL"]["total_received"], f'{stats["NORMAL"]["avg_latency"]:.2f}', f'{stats["NORMAL"]["throughput"]:.2f}'],
        ["LOW", stats["LOW"]["total_sent"], stats["LOW"]["total_received"], f'{stats["LOW"]["avg_latency"]:.2f}', f'{stats["LOW"]["throughput"]:.2f}']
    ]
    table = ax.table(cellText=table_data, loc='center', cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(10)
    table.scale(1.2, 1.2)
    plt.title('Performance Summary Statistics')
    plt.savefig('performance_summary.png', dpi=300, bbox_inches='tight')
    plt.close()

def main():
    """Glavna funkcija s argumentima za unos log datoteke."""
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    parser = argparse.ArgumentParser(description="Analyze FreeRTOS queue performance log.")
    parser.add_argument('--log', type=str, default="queue_run_01.log", help="Path to the log file")
    args = parser.parse_args()
    
    log_file = os.path.join(BASE_DIR, args.log)
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