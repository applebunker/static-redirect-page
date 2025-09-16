# Static Redirect Page Server

A simple Golang HTTP server that displays a customizable static page indicating that a site has moved to a new location.

## Features

- Clean, modern UI with responsive design
- Customizable message and redirect link via environment variables
- Built with Bazel for reproducible builds
- Comprehensive test coverage
- Cross-platform support

## Environment Variables

- `REDIRECT_MESSAGE`: The message to display on the page (default: "This page has been moved to a new location.")
- `REDIRECT_LINK`: The URL to redirect users to (default: "https://example.com")
- `PORT`: The port to run the server on (default: "8080")

## Building and Running

### Using Docker (Recommended for Production)

#### Quick Start

```bash
# Pull and run the latest image
docker run -p 8080:8080 ghcr.io/applebunker/static-redirect-page:latest

# Run with custom environment variables
docker run -p 8080:8080 \
  -e REDIRECT_MESSAGE="This site has moved to our new platform!" \
  -e REDIRECT_LINK="https://newsite.example.com" \
  ghcr.io/applebunker/static-redirect-page:latest
```

#### Building Docker Images

**Local build:**

```bash
./scripts/build-local.sh
```

**Multi-architecture build:**

```bash
./scripts/build-docker.sh [version] [registry]
```

**Push to GitHub Container Registry:**

```bash
# First, login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin

# Then push
./scripts/push-to-ghcr.sh [version] [github-username]
```

### Using Bazel (Development)

Build the project:

```bash
bazel build //...
```

Run tests:

```bash
bazel test //...
```

Run the server:

```bash
bazel run //:static-redirect-page
```

Run with custom environment variables:

```bash
REDIRECT_MESSAGE="This site has moved to our new platform!" REDIRECT_LINK="https://newsite.example.com" bazel run //:static-redirect-page
```

### Building a Standalone Binary

To create a standalone binary that can be run without Bazel:

```bash
bazel build //:static-redirect-page
# The binary will be available at: bazel-bin/static-redirect-page_/static-redirect-page
```

## Usage Examples

### Basic Usage

```bash
bazel run //:static-redirect-page
# Server starts on http://localhost:8080
```

### Custom Message and Link

```bash
REDIRECT_MESSAGE="We've moved to a better location!" REDIRECT_LINK="https://newcompany.com" bazel run //:static-redirect-page
```

### Custom Port

```bash
PORT=3000 bazel run //:static-redirect-page
# Server starts on http://localhost:3000
```

## Project Structure

- `main.go` - Main server implementation
- `main_test.go` - Unit tests
- `BUILD.bazel` - Bazel build configuration
- `MODULE.bazel` - Bazel module configuration
- `go.mod` - Go module definition
- `Dockerfile` - Multi-stage Docker build configuration
- `.dockerignore` - Docker build context exclusions
- `scripts/` - Build and deployment scripts
  - `build-local.sh` - Local Docker build script
  - `build-docker.sh` - Multi-architecture build script
  - `push-to-ghcr.sh` - GitHub Container Registry push script

## Testing

The project includes comprehensive tests that verify:

- Default behavior with no environment variables
- Custom message and link via environment variables
- HTTP response format and content
- Template rendering

Run tests with:

```bash
bazel test //...
```
