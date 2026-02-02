# shellcheck shell=bash disable=SC2016

# Track completed tasks
declare -A _tasks

# Run a task and its dependencies
#
# Usage: task::run <task>
#
# Arguments:
#   task  task name to execute
task::run() {
    local task="$1"
    local status="${_tasks[${task}]:-}"

    # Check if already executed
    if [[ -n "${status}" ]] && [[ "${status}" != "scheduled" ]]; then
        return 0
    fi

    # Verify task exists
    if ! declare -f "${task}" > /dev/null; then
        standard::raise "Unknown task: ${task}"
    fi

    # Mark as in-progress (detect circular dependencies)
    if [[ "${status}" == "in-progress" ]]; then
        standard::raise "Circular dependency detected: ${task}"
    fi
    _tasks[${task}]="in-progress"

    # Execute task
    "${task}"

    # Mark as completed
    _tasks[${task}]="completed"
}

# Schedule a task to run later
#
# Usage: task::schedule <task>
#
# Arguments:
#   task  task name to schedule
task::schedule() {
    local task="$1"

    # Check if already executed
    if [[ -n "${_tasks[${task}]:-}" ]]; then
        return 0
    fi

    # Mark as scheduled
    _tasks[${task}]="scheduled"
}

# Get next scheduled task
#
# Usage: task::next
task::next() {
    for task in "${!_tasks[@]}"; do
        if [[ "${_tasks[${task}]}" == "scheduled" ]]; then
            echo "${task}"
            return
        fi
    done

    return 1
}

# Run all scheduled tasks until completion
#
# Usage: task::work
#
# This function processes all scheduled tasks, allowing tasks to schedule
# additional tasks during execution. Continues until no scheduled tasks remain.
task::work() {
    local next

    while next="$(task::next)"; do
        task::run "${next}"
    done
}

# List all available tasks with a comment (first line only)
#
# Usage: task::list <namespace>
#
# Arguments:
#   namespace  Namespace to filter
task::list() {
    local comment

    for task in $(task::summary "$1"); do
        comment=$(standard::help "$1::${task}" | head -n1)

        printf "  %-12s  %s\n" "${task}" "${comment:-}"
    done
}

# Get available task names within a namespace
#
# Usage: task::summary <namespace>
#
# Arguments:
#   namespace  Namespace to filter
task::summary() {
    declare -F | grep "^declare -f $1::" | while read -r _ _ func; do
        echo "${func#"$1::"}"
    done | sort
}
