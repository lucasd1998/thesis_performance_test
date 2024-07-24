import csv
import os
import time
from datetime import datetime
import speedtest

def test_speed():
    try:
        st = speedtest.Speedtest()
        st.download()
        st.upload()
        results = st.results.dict()
        # Convert to Mbps
        return results['download'] / 1_000_000, results['upload'] / 1_000_000  
    except Exception as e:
        print(f"Error in the internet speed measurement: {e}")
        return None, None

def write_to_csv(timestamp, download_speed, upload_speed, filename="internet_speedtest_results.csv"):
    try:
        file_exists = os.path.isfile(filename)
        with open(filename, mode='a', newline='') as file:
            writer = csv.writer(file)
            if not file_exists:
                # write header
                writer.writerow(["Timestamp", "Download Speed (Mbps)", "Upload Speed (Mbps)"])  
            writer.writerow([timestamp, download_speed, upload_speed])
    except Exception as e:
        print(f"Error when writing to the CSV file: {e}")

def main():
    while True:
        download_speed, upload_speed = test_speed()
        if download_speed is not None and upload_speed is not None:
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            print(f"{timestamp} - Download: {download_speed:.2f} Mbps, Upload: {upload_speed:.2f} Mbps")
            write_to_csv(timestamp, download_speed, upload_speed)
        else:
            print("Speed measurement failed, try again in 30 seconds.")
        time.sleep(30)

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Unexpected error: {e}")
    finally:
        input("Press Enter to exit the program...")
