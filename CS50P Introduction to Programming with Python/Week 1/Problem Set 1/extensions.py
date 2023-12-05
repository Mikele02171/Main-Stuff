filename = input("File name: ")
filename.split()
if 'gif' in filename:
    print("image/gif")
elif 'jpeg' in filename or 'jpg' in filename:
    print("image/jpeg")
elif 'png' in filename:
    print("image/png")
elif 'pdf' in filename or 'PDF' in filename:
    print("application/pdf")
elif 'txt' in filename:
    print("text/plain")
elif 'zip' in filename:
    print("application/zip")
else:
    print("application/octet-stream")


