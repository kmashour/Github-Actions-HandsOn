#!/bin/bash

# Default to comparing against 'main', but allow overriding via arguments
TARGET_BRANCH="${1:-main}" 

echo "Checking for changed Python files against origin/$TARGET_BRANCH..."

# 1. Find changed files
# --name-only gives us just the file paths
# grep '\.py$' filters for only Python files
# || true prevents the script from crashing if grep finds nothing
CHANGED_FILES=$(git diff --name-only origin/$TARGET_BRANCH...HEAD | grep '\.py$' || true)

# 2. Exit early if there's nothing to check
if [ -z "$CHANGED_FILES" ]; then
    echo "No Python files changed. Skipping compilation check."
    exit 0
fi

echo "Found changed Python files:"
echo "$CHANGED_FILES"
echo "----------------------------------------"

# 3. Compile the files
# We set a failure flag so we can check all files before failing the pipeline
FAILED=0

for file in $CHANGED_FILES; do
    # Only check the file if it actually exists (skip files that were deleted in the PR)
    if [ -f "$file" ]; then 
        echo "Compiling $file..."
        
        # Run py_compile. If it returns a non-zero exit code, it failed.
        if ! python3 -m py_compile "$file"; then
            echo "❌ Syntax error detected in $file"
            FAILED=1
        fi
    fi
done

# 4. Final pipeline exit status
if [ $FAILED -ne 0 ]; then
    echo "----------------------------------------"
    echo "❌ py_compile check failed. Please fix the syntax errors above."
    exit 1  # This tells the CI/CD pipeline to fail the PR build
else
    echo "----------------------------------------"
    echo "✅ All changed Python files compiled successfully!"
    exit 0
fi