# Language tools

A set (currently, only one script!) of tools to help language study.

## Pre-requisites

* have Anki and AnkiConnect
* have an AWS account setup with appropriate keys (e.g. on my Mac, the keys are in `~/.aws/credentials`)
* Have Ruby installed

## Setup

* `gem install aws-sdk`
* Copy the file `settings.yml.example` to `settings.yml`, and edit it to match your setup and languages.

## `gen_cards.rb`: Generate Anki audio cards

This script creates different types of notes:

* "exposure" notes, for simply playing sentences
* "Question/answer" notes, similar to basic notes but with audio
* "Audio Cloze" notes, like regular cloze but with audio

See `samples/samples.txt` for examples.

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