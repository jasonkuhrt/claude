---
argument-hint: '[topic]'
description: Get current information on any topic
---

# Current Information Search

## Goal

- Get real-time, up-to-date information on any topic
- Focus on recent events, news, and developments

## Usage

- `/find-news [topic]` - Get current information on any topic

## Examples

- `/find-news AI developments this week`
- `/find-news TypeScript 5.7 features`
- `/find-news React 19 release`
- `/find-news GraphQL federation updates`

## Arguments

- All arguments: Used as search topic
- Include temporal context when relevant (e.g., "this week", "2024")

## Instructions

1. **Search with exa**:
   - Use web_search_exa with the query
   - Set numResults to 10 for comprehensive coverage
   - Include date context in query when relevant

2. **Filter for recency**:
   - Prioritize results from the last 30 days
   - Highlight breaking news or recent updates
   - Note publication dates for context

3. **Use specialized searches when applicable**:
   - company_research_exa for business news
   - github_search_exa for code updates
   - research_paper_search_exa for academic developments

4. **Synthesize findings**:
   - Group related information
   - Highlight key developments
   - Provide timeline of events if relevant
   - Include multiple perspectives

5. **Provide context**:
   - Explain why developments are significant
   - Connect to broader trends
   - Suggest follow-up searches for deeper dives