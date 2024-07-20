import requests

url = "https://8699-34-142-212-207.ngrok-free.app/predict"

data = {
    "instruction": "Who should I pick with the 10th pick in my standard fantasy draft",
    "input": "",
    "output": "" 
}

response = requests.post(url, json=data)

print(response.json())
