# Contributing to PUSTU Queue App

First off, thank you for considering contributing to PUSTU Queue App! It's people like you that make PUSTU Queue App such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the issue list as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* Use a clear and descriptive title
* Describe the exact steps which reproduce the problem
* Provide specific examples to demonstrate the steps
* Describe the behavior you observed after following the steps
* Explain which behavior you expected to see instead and why
* Include screenshots and animated GIFs if possible
* Include your environment details (OS, Flutter version, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* Use a clear and descriptive title
* Provide a step-by-step description of the suggested enhancement
* Provide specific examples to demonstrate the steps
* Describe the current behavior and explain which behavior you expected to see instead
* Explain why this enhancement would be useful
* List some other applications where this enhancement exists, if applicable

### Pull Requests

* Fork the repo and create your branch from `main`
* If you've added code that should be tested, add tests
* If you've changed APIs, update the documentation
* Ensure the test suite passes
* Make sure your code lints
* Issue that pull request!

## Development Process

1. Fork the repository
2. Create a new branch for your feature/fix
3. Write your code following our style guide
4. Write or adapt tests as needed
5. Update documentation as needed
6. Submit a pull request

### Style Guide

We use `flutter_lints` and custom rules defined in `analysis_options.yaml`. Please ensure your code follows these guidelines:

* Use meaningful variable and function names
* Write comments for complex logic
* Follow the Flutter style guide
* Keep functions small and focused
* Use proper error handling
* Write documentation for public APIs

### Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line

Example:
```
Add queue status notification feature

- Implement real-time queue status updates
- Add notification preferences in settings
- Update documentation for notification system

Fixes #123
```

### Testing

* Write tests for new features
* Update tests for bug fixes
* Ensure all tests pass before submitting PR
* Include both unit and widget tests where appropriate
* Test edge cases and error conditions

### Documentation

* Update README.md if needed
* Add comments to complex code
* Update API documentation
* Include example usage for new features
* Update CHANGELOG.md

## Project Structure

```
lib/
├── constants/      # App-wide constants and configurations
├── models/        # Data models and DTOs
├── providers/     # State management
├── screens/       # UI screens
├── services/      # Business logic and API services
├── utils/         # Utility functions
└── widgets/       # Reusable UI components
```

## Setting Up Development Environment

1. Install Flutter (latest stable version)
2. Clone the repository
3. Copy `.env.example` to `.env` and configure
4. Run `flutter pub get`
5. Run `flutter test`
6. Start coding!

## Release Process

1. Update version in `pubspec.yaml`
2. Update CHANGELOG.md
3. Create release branch
4. Run tests and checks
5. Submit PR for review
6. After approval, merge to main
7. Create release tag
8. Deploy to stores

## Getting Help

* Join our Discord channel
* Check the Wiki
* Read the documentation
* Contact the maintainers

## Recognition

Contributors will be recognized in:
* CONTRIBUTORS.md file
* Release notes
* Project documentation

Thank you for contributing to PUSTU Queue App!
