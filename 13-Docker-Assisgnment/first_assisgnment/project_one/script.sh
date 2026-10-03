```bash
#!/bin/bash

# ==========================================
# FastAPI + uv Project Generator
# ==========================================

PROJECT_NAME=$1

# Check project name
if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: ./create_fastapi_project.sh <project-name>"
    echo "Example: ./create_fastapi_project.sh pro01"
    exit 1
fi

echo "Creating FastAPI project: $PROJECT_NAME"

# ------------------------------------------
# Check uv
# ------------------------------------------

if ! command -v uv &> /dev/null; then
    echo "Error: uv is not installed."
    echo "Install uv first."
    exit 1
fi

# ------------------------------------------
# Create project directory
# ------------------------------------------

mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit 1

# ------------------------------------------
# Initialize uv project
# ------------------------------------------

uv init --name "$PROJECT_NAME"

# ------------------------------------------
# Add dependencies
# ------------------------------------------

uv add fastapi "uvicorn[standard]"

# ------------------------------------------
# Create src package structure
# ------------------------------------------

mkdir -p "src/$PROJECT_NAME"

touch "src/$PROJECT_NAME/__init__.py"

# ------------------------------------------
# Create FastAPI application
# ------------------------------------------

cat > "src/$PROJECT_NAME/main.py" <<EOF
from fastapi import FastAPI

app = FastAPI(
    title="$PROJECT_NAME API",
    version="0.1.0",
)


@app.get("/")
def home():
    return {
        "message": "Welcome to $PROJECT_NAME"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }


def main():
    import uvicorn

    uvicorn.run(
        "$PROJECT_NAME.main:app",
        host="127.0.0.1",
        port=8000,
        reload=True,
    )
EOF

# ------------------------------------------
# Create README
# ------------------------------------------

cat > README.md <<EOF
# $PROJECT_NAME

FastAPI project managed with uv.

## Run

\`\`\`bash
uv run $PROJECT_NAME
\`\`\`

## Development

\`\`\`bash
uv run uvicorn $PROJECT_NAME.main:app --reload
\`\`\`

## API Documentation

- http://127.0.0.1:8000/docs
- http://127.0.0.1:8000/redoc
EOF

# ------------------------------------------
# Sync dependencies and build project
# ------------------------------------------

uv sync

# ------------------------------------------
# Display project structure
# ------------------------------------------

echo ""
echo "=========================================="
echo "Project created successfully!"
echo "=========================================="
echo ""

echo "Project:"
pwd

echo ""
echo "Files:"
find . -maxdepth 3 -type f \
    ! -path "./.venv/*" \
    ! -path "./.git/*" \
    | sort

echo ""
echo "=========================================="
echo "To start the application:"
echo "=========================================="
echo ""
echo "cd $PROJECT_NAME"
echo "uv run $PROJECT_NAME"
echo ""
```
