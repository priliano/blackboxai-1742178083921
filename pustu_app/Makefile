# Flutter development commands
.PHONY: clean build run test coverage format lint deps upgrade outdated

# Default target
all: clean deps build

# Clean build files
clean:
	@echo "Cleaning..."
	@flutter clean
	@flutter pub get

# Get dependencies
deps:
	@echo "Getting dependencies..."
	@flutter pub get

# Upgrade dependencies
upgrade:
	@echo "Upgrading dependencies..."
	@flutter pub upgrade

# Check outdated packages
outdated:
	@echo "Checking outdated packages..."
	@flutter pub outdated

# Build the app
build:
	@echo "Building..."
	@flutter build apk --release
	@flutter build ios --release --no-codesign

# Run the app in debug mode
run:
	@echo "Running..."
	@flutter run

# Run all tests
test:
	@echo "Running tests..."
	@flutter test

# Run tests with coverage
coverage:
	@echo "Running tests with coverage..."
	@flutter test --coverage
	@genhtml coverage/lcov.info -o coverage/html
	@echo "Coverage report generated at coverage/html/index.html"

# Format code
format:
	@echo "Formatting code..."
	@dart format lib test
	@flutter format .

# Run static analysis
lint:
	@echo "Running static analysis..."
	@flutter analyze

# Generate code
generate:
	@echo "Generating code..."
	@flutter pub run build_runner build --delete-conflicting-outputs

# Watch and generate code
watch:
	@echo "Watching and generating code..."
	@flutter pub run build_runner watch --delete-conflicting-outputs

# Generate app icons
icons:
	@echo "Generating app icons..."
	@flutter pub run flutter_launcher_icons

# Generate splash screen
splash:
	@echo "Generating splash screen..."
	@flutter pub run flutter_native_splash:create

# Run integration tests
integration:
	@echo "Running integration tests..."
	@flutter test integration_test

# Build and run web version
web:
	@echo "Running web version..."
	@flutter run -d chrome

# Build release web version
web-release:
	@echo "Building web release..."
	@flutter build web --release

# Development environment setup
setup: deps generate icons splash
	@echo "Development environment setup complete"

# Run development server
dev: clean deps
	@echo "Starting development server..."
	@flutter run

# Run production build
prod: clean deps
	@echo "Building production release..."
	@flutter build apk --release
	@flutter build ios --release --no-codesign

# Docker commands
docker-build:
	@echo "Building Docker image..."
	@docker build -t pustu-app .

docker-run:
	@echo "Running Docker container..."
	@docker run -p 8000:8000 pustu-app

# Database commands
db-migrate:
	@echo "Running database migrations..."
	@flutter pub run drift_dev schema migrate

db-reset:
	@echo "Resetting database..."
	@flutter pub run drift_dev schema reset

# Documentation commands
docs:
	@echo "Generating documentation..."
	@dart doc .

# Localization commands
l10n-generate:
	@echo "Generating localizations..."
	@flutter gen-l10n

# Security commands
security-check:
	@echo "Running security checks..."
	@flutter pub run dependency_validator
	@flutter analyze

# CI/CD commands
ci: deps lint test coverage

# Help command
help:
	@echo "Available commands:"
	@echo "  make clean         - Clean build files"
	@echo "  make deps          - Get dependencies"
	@echo "  make upgrade       - Upgrade dependencies"
	@echo "  make outdated      - Check outdated packages"
	@echo "  make build         - Build the app"
	@echo "  make run           - Run the app in debug mode"
	@echo "  make test          - Run all tests"
	@echo "  make coverage      - Run tests with coverage"
	@echo "  make format        - Format code"
	@echo "  make lint          - Run static analysis"
	@echo "  make generate      - Generate code"
	@echo "  make watch         - Watch and generate code"
	@echo "  make icons         - Generate app icons"
	@echo "  make splash        - Generate splash screen"
	@echo "  make integration   - Run integration tests"
	@echo "  make web           - Run web version"
	@echo "  make web-release   - Build release web version"
	@echo "  make setup         - Development environment setup"
	@echo "  make dev           - Start development server"
	@echo "  make prod          - Build production release"
	@echo "  make docker-build  - Build Docker image"
	@echo "  make docker-run    - Run Docker container"
	@echo "  make db-migrate    - Run database migrations"
	@echo "  make db-reset      - Reset database"
	@echo "  make docs          - Generate documentation"
	@echo "  make l10n-generate - Generate localizations"
	@echo "  make security-check- Run security checks"
	@echo "  make ci            - Run CI tasks"
	@echo "  make help          - Show this help message"
