# Language tools

Tools to help language study.

  * [`gen_cards.rb`: Generate Anki audio cards](#-gen-cardsrb---generate-anki-audio-cards)
    + [Note types and cards.](#note-types-and-cards)
      - ["Exposure cards"](#-exposure-cards-)
    + [My usage - rough notes](#my-usage---rough-notes)
      - [Background](#background)
      - [Creating new notes](#creating-new-notes)
      - [Review workflow](#review-workflow)
    + [Install and set-up](#install-and-set-up)
      - [Pre-requisites](#pre-requisites)
      - [Setup](#setup)
    + [Usage](#usage)
    + [Sample](#sample)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>


## `gen_cards.rb`: Generate Anki audio cards

Given an input text file with sentences, this script creates different types of notes, one note per input line, with generate audio files.

For example, the text file line:

    Yo [tengo|tener] un gato

Would become the following "audio cloze card":

Front: Tener.  Yo <shhhh> un gato.   _(generated audio replaces the clozed word with "shhhh")_
Back: Yo tengo un gato

### Note types and cards.

There are a few different note types, which have different cards.

| Sample input line | Yields note | Front | Back |
| ----------------- | ----------- | ----- | ---- |
| `Yo tengo un gato.` | Exposure | Yo tengo un gato. | - |
| `¿Qué tienes?\|Un gato.` | Question/Answer | ¿Qué tienes? | Un gato. |
| `Yo [tengo\|tener] un gato` | Cloze | Yo _shhhh_ un gato. | Yo tengo un gato. |

(See [./samples/samples.txt](./samples/samples.txt) for examples.)

* "Exposure" notes: The card for this simply plays the sentence.  E.g., "Yo tengo un gato."  There's no real question/answer here, it's just audio for me to listen to the sentence and practice shadowing it if I want to.
* "Question/answer" notes: This is identical to Anki's "basic note", but with audio.
* "Audio Cloze" notes: Like regular cloze but with audio.

#### "Exposure cards"

In addition to the regular front/back type cards, each note type has an "exposure card", which just plays the full sentence (and answer if needed).  This card is always shown first.

I feel that these "exposure cards" are very important as they just ... expose me to what I'm trying to learn.  It's like bite-sized immersion, and lets me quickly review things I'm trying to get at, rather than wading through huge swaths of audio to find that one thing I need to study.

I just listen to these cards, and try to repeat them verbatim, aka shadowing.  The sentences are usually short.  Even for short sentences, I find this very useful, because if I can say it smoothly I've eliminated any mental tension due to sticky subjects or things I don't know well.


### My usage - rough notes

I'll try to give some ideas about how I currently use this tool, and my approach.

#### Background

I used to create cards with images, etc.  While that's good for very basic nouns (such as rock, scissors, paper), I didn't feel it was generally useful.

I started creating audio-only cards, and later found that it agrees with the ideas from [refold.la](https://refold.la/): basically, once you've gotten an idea of something in your language, the best way to learn is through immersion.  However, having done lots of immersion, I then started to feel it was overwhelming, and that I needed to create cards to regularly expose myself to grammatical constructions and vocab.  Hence, this tool, which I use to hammer ideas into my head.

#### Creating new notes

For any interesting sentence -- interesting due to new vocab, grammatical concept, etc -- I try to make a card.

Examples:

* Verb clozes
   * conjugations:  "Yo tengo un gato" becomes "Tener.  Yo <shhhhh> un gato".
   * verb articles: "Ella cumplió con sus deberes" becomes "Ella cumplió <shhhh> sus deberes".
* Some grammar exercises become Q&A notes.
   * front: "Ella le dió la cosa a él.  Ahora con pronombres:", back:  "Ella se la dió."
   * front: "Supongo que están las seis.  Otra manera de decir esto:", back: "Serán las seis."

When I can't think of what to do with a sentence, I'll just make an exposure note, so the sentence gets played.  e.g. for new vocab, this is usually good enough at first.

#### Review workflow

I have one filtered decks, "exposure_due", which I rebuild every day, and just listen to and shadow the sentences.

I have another filtered deck, "exposure_new", which adds a bunch of new exposure cards to my regular review schedule.

Then Anki takes care of the rest of the scheduling.

### Install and set-up

#### Pre-requisites

* have Anki and AnkiConnect
* have an AWS account setup with appropriate keys (e.g. on my Mac, the keys are in `~/.aws/credentials`)
* Have Ruby installed

#### Setup

* `gem install aws-sdk`
* Copy the file `settings.yml.example` to `settings.yml`, and edit it to match your setup and languages.

### Usage

In the `text` folder, create a text file with lines that you want to turn into Anki audio cards.

Run `ruby gen_cards.rb ./path/to/file.txt`

The above will:

* generate mp3 files using AWS Polly
* generate note data combining the sentences with the sound files
* post the cards to Anki using AnkiConnect

### Sample

Run the sample file, but don't actually generate audio files or post to AnkiConnect:

```
$ TEST=yes ruby gen_cards.rb samples/samples.txt
```