---
# YAML Frontmatter Configuration
# Tool restrictions: Allow all tools needed for PR feedback processing
argument-hint: '[pr-url-or-filter]'
description: Process PR review feedback systematically
---

# PR Feedback

# Documentation: https://cli.github.com/manual/gh_pr_view
# GitHub PR API: https://docs.github.com/en/rest/pulls/comments

## Goal

Process and address feedback comments from a pull request review systematically.

## Usage

- `/pr-feedback` - Process feedback from current branch's open PR
- `/pr-feedback [pr-number]` - Process feedback from a specific PR (e.g., `/pr-feedback 123`)
- `/pr-feedback [pr-url]` - Process feedback from a PR URL
- `/pr-feedback [filter]` - Process current branch's PR comments matching filter (e.g., "type", "test")

## Arguments

- All arguments: $ARGUMENTS
- First argument ($1): Optional PR URL, PR number, or comment filter keyword
- When no arguments: Process current branch's PR

## Instructions

1. **Gather PR feedback**:
   - Default (no arguments): Use `gh pr view --comments` to get comments from current branch's PR
   - If PR URL/number provided: Use `gh pr view --comments $1` to get all comments from that PR
   - If filter keyword provided: Get current branch's PR comments, then filter for "$1"

2. **Parse and organize feedback**:
   - Group comments by file/location
   - Identify comment type: bug fix, enhancement, style, question, etc.
   - Flag blocking vs non-blocking feedback
   - Note any comments already marked as resolved

3. **Create task list**:
   - Use TodoWrite to create tasks for each piece of actionable feedback
   - Prioritize blocking comments first
   - Group related comments into single tasks when appropriate
   - Include comment author and link in task description

4. **Process feedback**:
   - Work through tasks systematically
   - For each addressed comment:
     - Make the required code change
     - Run relevant tests
     - Mark task as completed
   - For discussion items:
     - Prepare response/clarification
     - Note if further discussion needed

5. **Verification**:
   - Run type checking: `pnpm check:types`
   - Run affected tests
   - Ensure all blocking feedback is addressed

6. **Summary**:
   - List all addressed comments
   - Note any unresolved discussions
   - Identify any comments requiring follow-up
   - Suggest commit message summarizing the changes

## Example Output

```
Analyzing PR feedback from #123...

Found 8 comments (3 blocking, 5 suggestions):

Blocking:
1. [@reviewer1] Fix type error in src/api/config.ts:45
2. [@reviewer2] Add missing test for edge case
3. [@reviewer1] Security: Validate input before processing

Suggestions:
4. [@reviewer3] Consider extracting to helper function
5. [@reviewer2] Could use more descriptive variable name
...

Creating task list to address feedback...

[Proceeds to work through each item]

✅ Summary:
- Fixed 3 blocking issues
- Implemented 3 suggestions
- 2 items need discussion (see comments #6, #7)

Suggested commit message:
"address PR feedback: fix type errors, add tests, improve validation"
```

## Best Practices

1. **Prioritization**: Always address blocking feedback before suggestions
2. **Commit Strategy**: Group related changes into logical commits with clear messages
3. **Communication**: Document reasoning for any deviations from requested changes
4. **Testing**: Run tests incrementally after each significant change
5. **Collaboration**: When unsure about feedback intent, ask for clarification
6. **Tracking**: Use TodoWrite to maintain visibility of progress

## Verified Capabilities

- ✅ Fetch PR comments using GitHub CLI (`gh pr view --comments`)
- ✅ Filter comments by keyword or file location
- ✅ Create structured task lists with TodoWrite
- ✅ Run type checking and tests
- ✅ Generate commit messages

## Limitations

- Cannot directly mark GitHub comments as resolved (requires web UI or API)
- Cannot fetch comments from private repos without proper authentication
- Filter matching is text-based, not semantic
- Cannot automatically detect if changes break other parts of codebase

## Notes

- Ensure `gh` CLI is authenticated: `gh auth status`
- For cross-repo PRs, use full URL format: `https://github.com/owner/repo/pull/123`
- Comments are fetched in chronological order
- Use `gh pr checks` to verify CI status before pushing