FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## Step 2: Add the GitHub Actions workflow

Create the folder structure `.github/workflows/` in your repo, then add a file called `docker-build.yml` inside it:
```
yure-yearly-app/
├── .github/
│   └── workflows/
│       └── docker-build.yml
├── Dockerfile
└── index.html