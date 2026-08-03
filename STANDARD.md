# The fairing standard

Copyright RAYFINITE LLC. Author: Pradeep Singala Reddy. MIT.

## Scope

**Everything you write from now on.** Marketing sites, blog posts, product UI and
microcopy, app store listings, social, email, press, public READMEs, and internal writing
too: specs, runbooks, review notes, commit messages, pull request bodies.

Internal documents are in scope because they leak outward constantly, through quoted specs,
screenshots, and drafts promoted to public without a rewrite. A habit practised only when
someone is watching is not a habit.

**Going forward only.** Do not launch a rewrite of historical internal documents. That burns
real effort for a reader who does not exist. The exception is anything about to be published
or quoted externally, which gets cleaned before it goes.

**This is about how writing reads, not how encouraging it is.** An incident report should
say what happened. A status update that softens bad news is worse than one that reads as
generated.

## 1. Punctuation

**The em dash (U+2014) is banned. So is the en dash (U+2013) used as a sentence separator.** No "sparingly"
allowance. The rule is absolute on purpose, because soft limits on this one get ignored in
practice by writers and drafting tools alike.

Every use has a better replacement, and choosing one usually improves the sentence.

| Instead of an em dash | Use | Example |
|---|---|---|
| Two joined thoughts | A period, two sentences | "Momentum builds. Yours can start today." |
| A light pause | A comma | "Start today, and let it build." |
| An aside | Parentheses | "Your streak (however short) still counts." |
| A lead-in to a list or explanation | A colon | "One thing matters most: showing up." |
| An interruption | Restructure the sentence | Rewrite so the interruption is not needed |
| Attribution after a quote | A hyphen with spaces, or a line break | "Keep going." - Ray |
| A numeric range | A hyphen | "2018-2026", "10-20 minutes" |
| Title, real subtitle follows | A colon | "The Vision: what we believe" |
| Title, brand name follows | A pipe | "Privacy Policy \| Example LLC" |

**Never use `--` as a substitute.** That is worse, not a workaround.

The absolute framing in this section, and the numeric-range remedy, follow
[Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) §9.G, which reached the same
conclusion first and for the same reason: a "sparingly" allowance gets ignored in practice.

An honest note on the reasoning. No search engine has confirmed em dash density as a
ranking factor, and Google's spam policies address scaled content abuse rather than any
particular character. What is true is that detection tools weight the
character heavily and readers have learned to notice it. The rule stands on perception
risk. Complying costs nothing, and being wrong the other way costs a page that reads as
generated.

## 2. Prose

The specific patterns are catalogued better elsewhere than we would catalogue them.
Use [blader/humanizer](https://github.com/blader/humanizer), which derives from
Wikipedia's "Signs of AI writing" guide and covers negative parallelisms, the rule of
three, promotional language, vague attributions, superficial `-ing` analyses, filler
vocabulary, passive voice, and hedging.

Two things that catalogue does not cover:

**Sentence rhythm is the hardest tell to fake.** Generated prose finds one sentence length
and stays there. Vary it deliberately. Let a long sentence run, then follow it with four
words. Real documents are lumpy, because some ideas need more room and a person writing
gives it to them.

**Write from inside the work.** The fastest way to read as human is a detail that could
not have been generated: what actually broke, what it cost, the number you measured, the
approach you tried first that did not work. Specificity is not a style preference here.
It is the evidence.

## 3. Substance

**No invented specifics.** No placeholder names, no stock avatars, no fabricated
testimonials, no suspiciously round statistics. If a number appears it must be real and
you must be able to say where it came from. A precise figure from your own work beats a
persuasive one you cannot source.

**Commit to a position.** Writing that surveys every side and concludes nothing is a
hallmark of generated text, because balance is the safe default. Take the position and
defend it. If you are genuinely uncertain, say so once, precisely, and move on.

## 4. Interface

Not restated here. The visual and layout tells are covered thoroughly by
[Nutlope/hallmark](https://github.com/Nutlope/hallmark) and
[Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill): identical three-column
feature rows, section-number eyebrows, version-label hero badges, fake product screenshots
built from `div` rectangles, default component-library styling left untouched.

Two of those projects contradict each other on punctuation. One prescribes the em dash,
the other bans it. Decide once, write the decision down, and stop re-deciding it per page.
This standard bans it.

## 5. The check

Two things are mechanical and should never be skipped.

```sh
./check.sh <built-output-directory>
```

It runs two checks against built output. **The dash check is a hard fail. The filler check
is advisory and does not fail the build.**

That split is deliberate. A dash either is or is not in the rendered text, so a machine can
decide it. Filler cannot be decided by a word list: "a platform deciding what to elevate" is
the literal verb, and a checker that fails the build on it teaches people to bypass the
gate. Then nobody looks at the one that matters. Advisory checks get read; crying-wolf
checks get `|| true` appended to them.

**Run it against built output, never source.** Comments and scripts are never rendered, so
the source count is misleading in both directions. On rayfinite.com the ten pages carried 201
occurrences in source and 155 in rendered content, 154 em dashes and one en dash. A
source-level check would have reported a problem a third larger than the one a reader
actually met.

That 155 figure is itself a correction. We first published 149 here, measured by stripping
every `<script>` block before counting. That silently removed the JSON-LD, where six of them
were sitting, and JSON-LD is exactly what a crawler reads. An independent reviewer counted
JSON-LD separately and caught it, which is why `check.sh` now keeps JSON-LD and strips only
the script bodies a reader never sees.

JSON-LD is the exception the checker deliberately keeps: it sits inside a `<script>` tag but
a crawler reads it, so it counts as user-facing.

**Count entities as well as characters.** `&mdash;` renders as an em dash and a checker that
only looks for the literal character reports clean on a page full of them. We shipped exactly
that mistake: a site we had declared clean was still serving 135 entity-encoded dashes, found
by a reviewer rather than by the tool. `check.sh` now decodes `&mdash;`, `&ndash;` and their
numeric forms before counting.

**Use `grep -E` with a plain unescaped pipe, and never wrap the pattern in `$'...'`.** We
shipped a basic regular expression first, escaped pipe, whole pattern inside `$'...'`, in the
very document that defined the rule. It found nothing on a file that plainly contained both
characters.

Our published explanation blamed BSD grep on macOS. An independent reviewer disproved that
in one command: BSD grep handles `\|` perfectly well. The actual cause was zsh's `$'...'` quoting
consuming the backslash, leaving a bare pipe that a basic regular expression reads as a
literal character. Separately, escaping the pipe inside an extended regular expression is
broken on every platform, because there it means a literal pipe.

Two lessons, and the second cost more. A check that can only pass is worse than no check.
And an explanation that sounds right is not a diagnosis: we had a confident theory, it was
wrong, and only an outside test caught it.

Then read it aloud. Anything you would not say to a person, cut.

## 6. Definition of done

A page is not publishable until all three hold:

1. `check.sh` returns clean against the built output.
2. Someone has read the rendered page and can point to at least one specific, sourceable
   detail that a generator could not have produced.
3. No claim in it is one you cannot support.

## Why bother

You publish because you have something true and specific to say. Content that reads as
generated gets discounted before the argument is heard. The writing is the first evidence
of the standard you hold everywhere else, and it is the piece a reader can evaluate
without installing anything.
