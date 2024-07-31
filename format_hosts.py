wqimport yaml
from collections import defaultdict

# Load the extracted hosts data
with open('extracted_hosts.yml') as f:
    data = yaml.safe_load(f)

# Initialize a dictionary to hold the job groups
job_groups = defaultdict(list)

# Group hosts based on the first 2-3 characters of their names
for item in data:
    key = item['key']
    host = key.split('.')[-1]
    prefix = host[:2]  # You can adjust this to host[:3] if needed
    job_groups[prefix].append(f"{host}:9100")

# Create the final data structure
final_data = []

for prefix, targets in job_groups.items():
    job = {
        "job_name": prefix,
        "scrape_interval": "15s",
        "scrape_timeout": "14s",
        "static_configs": [
            {
                "targets": targets
            }
        ]
    }
    final_data.append(job)

# Save the final structure to a new YAML file
with open('formatted_output.yml', 'w') as f:
    yaml.dump(final_data, f, default_flow_style=False)

print("Formatted data saved to formatted_output.yml"

