# The hand-finished standard

Copyright RAYFINITE LLC. Author: Pradeep Singala Reddy. MIT.

## Scope

Everything a person outside the organisation can see: marketing sites, blog posts, product
UI and microcopy, app store listings, social, email, press, public repository READMEs and
documentation.

Internal writing is exempt and should stay plainly honest. A build log does not need a
voice, an incident report should not be uplifting, and a status update that softens bad
news is worse than one that reads as generated.

## 1. Punctuation

**The em dash is banned. So is the en dash used as a sentence separator.** No "sparingly"
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

An honest note on the reasoning. No search engine has confirmed em dash density as a
ranking factor, and the major published guidance targets unhelpful and mass-produced
content rather than any character. What is true is that detection tools weight the
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

It runs the dash check and the filler-vocabulary check against built output and exits
non-zero on a finding.

**Run it against built output, never source.** Comments and scripts are never rendered, so
the source count is misleading in both directions. Our own site carries 45 em dashes in
HTML comments and zero in anything a reader or crawler sees. That is a pass, and a
source-level check would have called it a failure.

**The dash grep must use `-E`.** The GNU `\|` alternation spelling finds nothing on macOS
BSD grep and exits clean against a file that plainly contains both characters. We shipped
that spelling first, in the very document that defined the rule. A check that can only
pass is worse than no check, because it also stops anyone from looking.

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
