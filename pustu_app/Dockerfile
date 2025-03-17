# Stage 1: Build the Flutter web app
FROM debian:latest AS builder

# Install essential packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
ENV FLUTTER_VERSION="3.16.0"
ENV FLUTTER_HOME=/flutter
ENV PATH=$FLUTTER_HOME/bin:$PATH

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git $FLUTTER_HOME

# Enable Flutter web
RUN flutter config --enable-web

# Copy the app files
WORKDIR /app
COPY . .

# Get app dependencies
RUN flutter pub get

# Build the app for web
RUN flutter build web --release

# Stage 2: Serve the app using Nginx
FROM nginx:alpine

# Copy the built app to nginx
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

# Metadata
LABEL maintainer="PUSTU Queue App Team <team@pustuapp.com>"
LABEL version="1.0.0"
LABEL description="PUSTU Queue App Web Application"

# Build-time arguments
ARG BUILD_DATE
ARG VCS_REF

# Labels following OCI image spec
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.revision=$VCS_REF
LABEL org.opencontainers.image.title="PUSTU Queue App"
LABEL org.opencontainers.image.description="Web application for PUSTU Queue management system"
LABEL org.opencontainers.image.vendor="PUSTU"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.source="https://github.com/yourusername/pustu_app"
LABEL org.opencontainers.image.licenses="MIT"
