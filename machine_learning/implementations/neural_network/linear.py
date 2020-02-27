import numpy as np
import math

class Linear():
    def __init__(self, in_feature, out_feature, weight_init_fn, bias_init_fn):

        """
        One linear layer (includes all neurons in layer)
        (based on PyTorch linear layer)
        
        Arguments:
            W (np.array): (in feature, out feature)
            dW (np.array): (in feature, out feature)
            momentum_W (np.array): (in feature, out feature)

            b (np.array): (1, out feature)
            db (np.array): (1, out feature)
            momentum_B (np.array): (1, out feature)
        """

        self.W = weight_init_fn(in_feature, out_feature)
        self.b = bias_init_fn(out_feature)

        self.dW = np.zeros((in_feature, out_feature))
        self.db = np.zeros((1, out_feature))

        self.momentum_W = np.zeros((in_feature, out_feature))
        self.momentum_b = np.zeros((1, out_feature))

    def __call__(self, x):
        return self.forward(x)

    def forward(self, x):
        """
        Forward pass through linear layer 
        
        Argument:
            x (np.array): (batch size, in feature)
        Return:
            out (np.array): (batch size, out feature)
        """
        self.x = x
        output = np.dot(x, self.W) + self.b
        return output

    def backward(self, delta):
        """
        Backward pass through linear layer
        
        Argument:
            delta (np.array): (batch size, out feature)
        Return:
            out (np.array): (batch size, in feature)
        """
        
        self.dW = np.dot(self.x.T, delta)/self.x.shape[0]
        self.db = np.sum(delta, axis=0, keepdims=True)/self.x.shape[0]
        return np.dot(delta, self.W.T)
        