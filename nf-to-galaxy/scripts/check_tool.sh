#!/bin/bash
# check_tool.sh
# Systematic Galaxy tool availability checker
# Usage: ./check_tool.sh TOOL_NAME [LOCAL_TOOLS_IUC_PATH]

set -e

TOOL_NAME=$1
LOCAL_IUC=${2:-""}

# Common locations to check for local tools-iuc
COMMON_PATHS=(
    "$HOME/Documents/brc-analytics/tools-iuc"
    "$HOME/galaxy/tools-iuc"
    "$HOME/tools-iuc"
    "./tools-iuc"
    "../tools-iuc"
)

if [ -z "$TOOL_NAME" ]; then
    echo "Usage: $0 TOOL_NAME [LOCAL_TOOLS_IUC_PATH]"
    echo ""
    echo "Examples:"
    echo "  $0 hyphy"
    echo "  $0 iqtree ~/Documents/brc-analytics/tools-iuc"
    exit 1
fi

echo "=========================================="
echo "Galaxy Tool Availability Check"
echo "Tool: $TOOL_NAME"
echo "=========================================="

# 1. Check local tools-iuc clone
echo -e "\n1. LOCAL TOOLS-IUC CLONE"
echo "----------------------------------------"

FOUND_LOCAL=0
if [ -n "$LOCAL_IUC" ] && [ -d "$LOCAL_IUC" ]; then
    echo "Checking provided path: $LOCAL_IUC"
    LOCAL_PATH="$LOCAL_IUC"
    FOUND_LOCAL=1
else
    for path in "${COMMON_PATHS[@]}"; do
        if [ -d "$path" ]; then
            echo "Found local clone: $path"
            LOCAL_PATH="$path"
            FOUND_LOCAL=1
            break
        fi
    done
fi

if [ $FOUND_LOCAL -eq 1 ]; then
    echo -e "\nSearching for tool directories..."
    find "$LOCAL_PATH/tools" -type d -iname "*${TOOL_NAME}*" 2>/dev/null || echo "No matching directories found"
    
    echo -e "\nSearching for tool XML files..."
    find "$LOCAL_PATH/tools" -type f -name "*.xml" -exec grep -l "$TOOL_NAME" {} \; 2>/dev/null | head -5 || echo "No matching XML files found"
    
    echo -e "\nResult: Check paths above"
else
    echo "No local tools-iuc clone found"
    echo "Checked locations:"
    for path in "${COMMON_PATHS[@]}"; do
        echo "  - $path"
    done
fi

# 2. GitHub tools-iuc
echo -e "\n2. GITHUB TOOLS-IUC"
echo "----------------------------------------"
echo "Search URL:"
echo "  https://github.com/galaxyproject/tools-iuc/search?q=${TOOL_NAME}"
echo ""
echo "Browse tools directory:"
echo "  https://github.com/galaxyproject/tools-iuc/tree/main/tools"
echo ""
echo "Direct tool path (if exists):"
echo "  https://github.com/galaxyproject/tools-iuc/tree/main/tools/${TOOL_NAME}"

# 3. Known repositories
echo -e "\n3. KNOWN GALAXY TOOL REPOSITORIES"
echo "----------------------------------------"
echo "GenOuest (genomics, annotation):"
echo "  https://github.com/genouest/galaxy-tools/search?q=${TOOL_NAME}"
echo ""
echo "bgruening (cheminformatics, diverse):"
echo "  https://github.com/bgruening/galaxytools/search?q=${TOOL_NAME}"
echo ""
echo "ARTbio (RNA-seq, small RNA):"
echo "  https://github.com/ARTbio/tools-artbio/search?q=${TOOL_NAME}"
echo ""
echo "tools-devteam (legacy core tools):"
echo "  https://github.com/galaxyproject/tools-devteam/search?q=${TOOL_NAME}"

# 4. Galaxy ToolShed
echo -e "\n4. GALAXY MAIN TOOLSHED"
echo "----------------------------------------"
echo "Search URL:"
echo "  https://toolshed.g2.bx.psu.edu/repository/browse_repositories?f-free-text-search=${TOOL_NAME}"

# 5. Summary
echo -e "\n=========================================="
echo "NEXT STEPS"
echo "=========================================="
echo "1. Check local results above (if found)"
echo "2. Visit GitHub tools-iuc search URL"
echo "3. If not in tools-iuc, check other repos"
echo "4. If not found anywhere, check ToolShed"
echo "5. If still not found, plan to create custom tool"
echo ""
echo "Remember to:"
echo "  - Verify tool quality and maintenance status"
echo "  - Check for recent commits"
echo "  - Look for test data"
echo "  - Note the tool ID for workflow integration"
echo "=========================================="
