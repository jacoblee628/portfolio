import numpy as np
import os

class Criterion(object):
    """ Interface for various loss functions. """

    def __init__(self):
        self.logits = None
        self.labels = None
        self.loss = None

    def __call__(self, x, y):
        return self.forward(x, y)

    def forward(self, x, y):
        raise NotImplemented

    def derivative(self):
        raise NotImplemented

class SoftmaxCrossEntropy(Criterion):
    """ Softmax Cross Entropy Loss. """

    def __init__(self):
        super(SoftmaxCrossEntropy, self).__init__()

    def forward(self, x, y):
        """
        Forward pass
        
        Argument:
            x (np.array): (batch size, 10)
            y (np.array): (batch size, 10)
        Return:
            out (np.array): (batch size, )
        """
        self.logits = x
        self.labels = y
        
        self.s = softmax(self.logits)
        self.loss = - np.sum(self.labels * np.log(self.s), axis=1)
        return self.loss

    def derivative(self):
        """
        Backwards pass
        
        Return:
            out (np.array): (batch size, 10)
        """
        return self.s - self.labels


def softmax(x):
    """ Computes softmax with logsumexp trick """
    a = np.max(x, axis=1, keepdims=True)
    denom = a + np.log(np.sum(np.exp(x - a), axis=1, keepdims=True))
    return np.exp(x - denom)