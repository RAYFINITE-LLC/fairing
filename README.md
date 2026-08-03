# hand-finished

**A standard for work that reads as made by a person.**

Agents draft a great deal of what gets published now. That is not the problem. The
problem is when the artifact announces it: the punctuation, the rhythm, the stock
vocabulary, the paragraph that summarizes the paragraphs above it. A reader who notices
those things stops reading the argument and starts reading the process. And a reader who
suspects the words were not considered has no reason to believe the product was.

In carpentry, rough work is the framing nobody sees. Finish work is the trim, the doors,
the surfaces people actually touch and judge. This repository is about the finish.

The name is the claim, and it is deliberately narrow. It does not say a machine was never
involved. It says the visible layer is held to a standard a person set, and that a person
signed off on it.

## What is here

| File | What it does |
|---|---|
| [`STANDARD.md`](STANDARD.md) | The standard itself. Scope, the rules, and the definition of done. |
| [`check.sh`](check.sh) | The mechanical half. Two greps you can run in CI today. |
| [`examples/before-after.md`](examples/before-after.md) | Real edits from our own site, with the reasoning for each choice. |

## The short version

1. **No em dash.** No en dash used as a separator. It is the most-cited tell and the
   cheapest one to remove. Every use has a better replacement, and picking one usually
   improves the sentence.
2. **No prose tells.** Uniform sentence rhythm, the rule of three on every heading,
   "not X, but Y" three times a page, filler vocabulary, stacked hedges, a closing
   paragraph that restates the opening.
3. **No invented specifics.** No placeholder names, no stock avatars, no round statistics
   you cannot source. If a number appears, it must be real.
4. **Write from inside the work.** The fastest way to read as human is a detail a
   generator could not have: what broke, what it cost, what you tried first that did not
   work.
5. **Check the built output, not the source.** Comments and scripts are never rendered,
   so a source count is misleading in both directions.

## Run the check

```sh
./check.sh dist/          # or build/, public/, _site/, wherever your output lands
```

It exits non-zero on a finding, so it drops into CI without ceremony.

Some files legitimately contain the patterns: changelogs quoting old copy, style guides,
vendored third-party content, before-and-after documentation. List them one path substring
per line in `.hand-finished-ignore`. This repository uses one, because a document that
explains the em dash has to show you an em dash. That is the only exception we grant, and
it is written down rather than special-cased inside the checker.

One detail worth stating, because it cost us: the dash check **must** use `grep -E`. The
GNU `\|` alternation spelling finds nothing on macOS and exits clean on every page, so the
check passes whether or not the page is clean. We shipped that version first. A gate that
cannot fail is worse than no gate, because it also stops anyone from looking.

## What this is not

It is not an argument against writing with AI. We use agents daily and this standard was
drafted with them. It is a quality bar for what leaves the building.

It is also not a detector. Tools that score text for AI probability are unreliable in both
directions, and writing to beat one is its own kind of tell. The rules here are about
whether the writing is specific, committed, and shaped by someone who cared. Text that
clears that bar tends to clear the detectors as a side effect, which is the correct
ordering.

## Prior art we route to rather than repackage

Two excellent MIT projects cover ground this standard leans on. We point at them and do
not vendor copies into this repository, because a second copy is a copy that drifts, and
because their authors deserve the traffic:

- [blader/humanizer](https://github.com/blader/humanizer) for the prose-pattern catalogue.
  It derives from Wikipedia's community-maintained "Signs of AI writing" guide, so its
  patterns are documented rather than recalled.
- [Nutlope/hallmark](https://github.com/Nutlope/hallmark) and
  [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) for the visual and
  layout tells, which this standard deliberately does not restate.

If you only adopt one thing from this repository, adopt `check.sh` and point it at your
build output. The rest is judgment, and judgment does not install.

## Related

Part of a set of small, public disciplines from RAYFINITE:

- [objective-contracts](https://github.com/RAYFINITE-LLC/objective-contracts) for
  delegating one bounded task to an agent
- [standing-orders](https://github.com/RAYFINITE-LLC/standing-orders) for recurring
  autonomous jobs
- [agent-charters](https://github.com/RAYFINITE-LLC/agent-charters) for standing agents
  that persist across tasks

## Licence

MIT. Copyright RAYFINITE LLC. Author: Pradeep Singala Reddy.

Use it, fork it, argue with it. If you disagree with a rule, the useful thing is to say
which one and why.
