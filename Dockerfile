FROM python:3.11-slim

# 安装 ffmpeg
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 安装依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制项目文件
COPY . .

# 输出目录
RUN mkdir -p data/output data/sources

CMD ["python", "main.py"]
