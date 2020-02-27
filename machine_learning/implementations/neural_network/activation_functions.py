import numpy as np
import os


class Activation(object):
    """ General interface for activation functions """

    def __init__(self):
        self.state = None

    def __call__(self, x):
        return self.forward(x)

    def forward(self, x):
        raise NotImplemented

    def derivative(self):
        raise NotImplemented


class Identity(Activation):
    """ Identity function (already implemented) """

    # This class is a gimme as it is already implemented for you as an example

    def __init__(self):
        super(Identity, self).__init__()

    def forward(self, x):
        self.state = x
        return x

    def derivative(self):
        return 1.0

class Sigmoid(Activation):
    """ Sigmoid activation function """

    def __init__(self):
        super(Sigmoid, self).__init__()

    def forward(self, x):
        a = 1 / (1 + np.exp(-x))
        self.state = a
        return a

    def derivative(self):
        x = self.state
        a = x * (1 - x)
        return a


class Tanh(Activation):
    """ Tanh activation function """

    def __init__(self):
        super(Tanh, self).__init__()

    def forward(self, x):
        a = (np.exp(x) - np.exp(-x)) / (np.exp(x) + np.exp(-x))
        self.state = a
        return a

    def derivative(self):
        x = self.state
        a = 1 - np.square(x)
        return a
        


class ReLU(Activation):
    """ ReLU activation function """

    def __init__(self):
        super(ReLU, self).__init__()

    def forward(self, x):
        a = np.maximum(0, x)
        self.state = a
        return a

    def derivative(self):
        x = self.state
        x[x < 0] = 0
        x[x > 0] = 1
        return x
