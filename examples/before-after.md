# Before and after

Every example below is a real edit from rayfinite.com, made on 2026-08-03 while removing
154 em dashes from ten pages. Nothing here is invented, which is the point: the standard
asks you to write from inside the work, so its own examples should come from work.

The useful part is not the replacement. It is why that replacement and not another one.

## Titles: colon or pipe, decided by what follows

```
- <title>RAYFINITE — Technology, Commerce & Media</title>
+ <title>RAYFINITE: Technology, Commerce & Media</title>
```

```
- <title>Privacy Policy — RAYFINITE LLC</title>
+ <title>Privacy Policy | RAYFINITE LLC</title>
```

Two different replacements for what looks like the same pattern. A colon when the second
half is a real subtitle that elaborates the first. A pipe when it is only the brand,
which is the conventional title separator and reads better than forcing a colon into a
relationship that is not there.

This is the first thing a blind substitution gets wrong. Replace every em dash with a
comma and the homepage title becomes `RAYFINITE, Technology, Commerce & Media`, which
reads as a list of three unrelated things.

## Paired dashes: parentheses, not two commas

```
- We build apps, platforms, and tools — from early prototype to shipped
- product — using modern technology where it concretely helps.
+ We build apps, platforms, and tools (from early prototype to shipped
+ product) using modern technology where it concretely helps.
```

The sentence already contains a comma-separated list. Wrapping the aside in two more
commas gives you four commas doing three different jobs, and the reader has to
re-parse. Parentheses mark the aside as subordinate and leave the list intact.

Same reasoning on a privacy page, where the clause was longer and the failure worse:

```
- for the purposes described in this Privacy Policy — for example, to respond
- to and maintain a record of your inquiry — and as required to comply with
+ for the purposes described in this Privacy Policy (for example, to respond
+ to and maintain a record of your inquiry) and as required to comply with
```

## A new thought takes a period

```
- because governance that only works inside one company isn't governance —
- it's a private habit.
+ because governance that only works inside one company isn't governance.
+ It's a private habit.
```

The clause after the dash is not an aside or an elaboration. It is the punchline. Giving
it its own sentence makes it land harder than the dash did, which is the general case:
the em dash usually hides a sentence that wanted to exist.

## An elaboration takes a colon

```
- A focused portfolio — one live product today, more on the way.
+ A focused portfolio: one live product today, more on the way.
```

```
- Objective Contract is the unit of work for one bounded task — the smallest
- thing we hand an agent that still counts as real accountability.
+ Objective Contract is the unit of work for one bounded task: the smallest
+ thing we hand an agent that still counts as real accountability.
```

When the second half defines or expands the first, the colon says so explicitly. A dash
leaves the relationship ambiguous.

## An interruption takes commas

```
- an invitation for a well-intentioned agent to wander, and for nobody —
- including the agent — to know when it's done
+ an invitation for a well-intentioned agent to wander, and for nobody,
+ including the agent, to know when it's done
```

Here commas are right and parentheses would be wrong, because "including the agent" is
the emphatic part of the sentence. Parentheses would demote it.

## When the fix makes it worse, fix it again

First pass:

```
- <strong>WeatherHappiness</strong> — a well-being companion that reveals how
- the weather shapes your mood, energy, and sleep — is in development.
~ <strong>WeatherHappiness</strong>, a well-being companion that reveals how
~ the weather shapes your mood, energy, and sleep, is in development.
```

That is compliant and bad. The inner clause already has two commas, so the outer pair
disappears into them and the sentence stalls before "is in development". Second pass:

```
+ <strong>WeatherHappiness</strong> (a well-being companion that reveals how
+ the weather shapes your mood, energy, and sleep) is in development.
```

We only caught this by reading the rendered page, not the diff. The diff looked fine.

## The one the eye missed

```
- <figcaption>16–24px favicon</figcaption>
+ <figcaption>16-24px favicon</figcaption>
```

An en dash in a numeric range, on a page we had already declared clean. The manual sweep
never found it because the manual sweep only ever searched for `—`. `check.sh` searches
for both and found it in the first run, on a page a human had signed off.

That is the argument for the tool over the eye. Not that the tool is smarter, but that it
does not get bored and does not decide it already knows the answer.

## What none of this fixes

Every edit above is mechanical enough that a careful person can do it. None of it makes
writing good. The page that now has zero em dashes can still be vague, uncommitted, and
padded with the phrases nobody says out loud. Clearing the check is the floor, not the
work.
