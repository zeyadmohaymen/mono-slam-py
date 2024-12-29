FROM python:3.8-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    libglew-dev \
    ffmpeg \
    libavcodec-dev \
    libavutil-dev \
    libavformat-dev \
    libswscale-dev \
    libdc1394-22-dev \
    libraw1394-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff5-dev \
    libopenexr-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install pangolin
RUN git clone https://github.com/uoip/pangolin.git && \
    cd pangolin && \
    mkdir build && \
    cd build && \
    cmake .. && \
    # Apply fix for make error as mentioned in the GitHub issue
    sed -i 's/CMAKE_CXX_STANDARD 11/CMAKE_CXX_STANDARD 14/g' ../CMakeLists.txt && \
    make -j8 && \
    cd .. && \
    # Apply fix for setup.py install error
    sed -i 's/if not self.dry_run:/if True:/g' setup.py && \
    python setup.py install

# Clone the mono-slam repository
RUN git clone https://github.com/zeyadmohaymen/mono-slam-py.git

# Set the working directory to the cloned repository
WORKDIR /app/mono-slam-py

# Command to run your application (adjust the script name if needed)
CMD ["python", "main.py"]
