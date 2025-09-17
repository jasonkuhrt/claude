---
argument-hint: '[topic]'
description: Deep AI-powered research on complex topics
---

# Deep Research

## Goal

- Conduct comprehensive AI-powered research on any topic
- Synthesize findings from multiple sources into a detailed report

## Usage

- `/find-deep [topic]` - Research any topic comprehensively

## Examples

- `/find-deep state management libraries for React in 2025`
- `/find-deep quantum computing breakthroughs 2024`
- `/find-deep AI safety research landscape`

## Arguments

- All arguments: Used as research topic
- Be specific for best results

## Instructions

1. **Start deep research**:
   - Use exa's deep_researcher_start with the provided topic
   - Choose model based on complexity:
     - Use "exa-research" for most queries (15-45s)
     - Use "exa-research-pro" for very complex topics (45s-2min)

2. **Monitor progress**:
   - Poll with deep_researcher_check every 10 seconds
   - Continue until status is "completed"
   - Show progress updates to user

3. **Present findings**:
   - Format the research report clearly
   - Include key findings and sources
   - Highlight actionable insights
   - Provide summary at the beginning

4. **Follow-up options**:
   - Suggest related searches if applicable
   - Offer to dive deeper into specific aspects
   - Provide links to primary sources