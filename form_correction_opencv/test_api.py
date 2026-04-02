import requests

url = "http://127.0.0.1:5000/detect"

files = {
    "file": open("test.jpg", "rb")  # make sure this image exists
}

response = requests.post(url, files=files)

print(response.json())