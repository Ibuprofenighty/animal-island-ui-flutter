# ADR 0004: Documentation Sync Automation

## Context
Component libraries suffer when documentation or skill references drift from the actual code.

## Decision
A dedicated CI script (`scripts/check-docs-sync.mjs`) validates 100% component discovery, line count caps, and bilingual file parity.

## Consequences
Discrepancies block CI and are prevented from merging.
