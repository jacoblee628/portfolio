# Phoneme Prediction with Deep Learning

This neural network identifies [phonemes](https://en.wikipedia.org/wiki/Phoneme) from audio samples of speech.

It was developed using Python/PyTorch, and trained on an Amazon Web Services (AWS) EC2 GPU cluster. The training took around 20 minutes per model.

We were required to use only simple neural networks, so model tuning and architecture was important.

<b>It achieves around 62% accuracy</b>.

The data was acquired from the [Wall Street Journal Speech Dataset](https://catalog.ldc.upenn.edu/LDC94S13A).

### Methodology
<img src=https://miro.medium.com/max/1182/1*OOTqBsjpuXyfYJVdPxWtBA.png>

The input audio clips are transformed into [Mel-frequecncy spectrograms](https://en.wikipedia.org/wiki/Mel-frequency_cepstrum) (see above) frames.

Each frame is 25ms wide.

Because each frame is so short, we add 6 additional frames from the original ordering on side (frame). This is done during pre-processing.

We then train the model on each point (13 frames, with the original frame in the middle) and generate a label for the center frame.

## Contact
Email: sglee@andrew.cmu.edu  
LinkedIn: https://www.linkedin.com/in/jacoblee628/
