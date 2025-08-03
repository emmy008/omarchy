#!/bin/bash

echo "🧪 Testing Omarchy Ubuntu 25.04 compatibility..."
echo "This will test the core installation scripts in a Docker container"
echo

# Create test results directory with proper permissions
mkdir -p test-results
chmod 777 test-results

# Clean up any existing container
docker compose -f docker-compose.test.yml down 2>/dev/null || true

# Build and run the test
echo "Building test container..."
if docker compose -f docker-compose.test.yml build; then
    echo "Running tests..."
    if docker compose -f docker-compose.test.yml up; then
        echo
        echo "✅ Test completed! Check test-results/test-output.log for details"
        echo
        # Show summary of results
        if [[ -f "test-results/test-output.log" ]]; then
            echo "=== Test Summary ==="
            grep -E "\[TEST\]|\[ERROR\]|\[WARNING\]" test-results/test-output.log | tail -20
        fi
    else
        echo "❌ Test execution failed"
        exit 1
    fi
else
    echo "❌ Failed to build test container"
    exit 1
fi

# Clean up
docker compose -f docker-compose.test.yml down