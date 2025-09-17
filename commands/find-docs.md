---
argument-hint: '[query]'
description: Search technical documentation efficiently
---

# Documentation Search

## Goal

- Search and retrieve technical documentation efficiently using ref MCP
- Fall back to web search if documentation not found in ref

## Usage

- `/find-docs [query]` - Search for documentation on any topic
- `/find-docs [library] [specific-query]` - Search within specific library docs

## Examples

- `/find-docs react hooks`
- `/find-docs typescript decorators`
- `/find-docs graphql schema design`
- `/find-docs effect schema`
- `/find-docs ref_src=private my-private-docs` - Search private docs

## Arguments

- All arguments: Used as search query
- Special: Include "ref_src=private" to search user's private docs

## Instructions

1. **Search with ref MCP**:
   - Use ref_search_documentation with the query
   - For private docs, append "ref_src=private" to search user's docs
   - Show search results with relevance

2. **Retrieve full content**:
   - Use ref_read_url on the most relevant result
   - Extract and display the relevant sections
   - Format code examples properly

3. **Fallback to exa if needed**:
   - If ref returns no results, use exa's web_search_exa
   - Focus on official documentation sites
   - Filter for recent, authoritative sources

4. **Present documentation**:
   - Show the most relevant sections first
   - Include code examples
   - Provide links to full documentation
   - Highlight important notes or warnings

5. **Additional resources**:
   - Suggest related documentation
   - Link to examples or tutorials
   - Mention alternative resources if applicable