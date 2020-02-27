import numpy as np
import os
import sys

from loss import *
from activation import *
from batchnorm import *
from linear import *


class NeuralNetwork(object):
    """
    Implementation of a simple neural network (multilayer perceptron)
    """

    def __init__(self, input_size, output_size, hiddens, activations, weight_init_fn,
                 bias_init_fn, criterion, lr, momentum=0.0, num_bn_layers=0):

        self.train_mode = True
        self.num_bn_layers = num_bn_layers
        self.bn = num_bn_layers > 0
        self.nlayers = len(hiddens) + 1
        self.input_size = input_size
        self.output_size = output_size
        self.activations = activations
        self.criterion = criterion
        self.lr = lr
        self.momentum = momentum
        
        layer_sizes = [self.input_size] + hiddens + [self.output_size]

        self.linear_layers = [Linear(layer_sizes[n], layer_sizes[n + 1],
                                     weight_init_fn, bias_init_fn)
                              for n in range(self.nlayers)]
        
        # If batch norm, add batch norm layers into the list 'self.bn_layers'
        if self.bn:
            self.bn_layers = [BatchNorm(layer_sizes[n + 1]) for n in range(self.num_bn_layers)]
        
    def forward(self, x):
        """
        Argument:
            x (np.array): (batch size, input_size)
        Return:
            out (np.array): (batch size, output_size)
        """
        for l in range(self.nlayers):
            x = self.linear_layers[l](x)
            if self.bn and l < self.num_bn_layers:
                    x = self.bn_layers[l](x, not self.train_mode)
            x = self.activations[l](x)
        self.output = x
        return x

    def zero_grads(self):
        map(lambda l: l.dW.fill(0,0), self.linear_layers)
        map(lambda l: l.db.fill(0,0), self.linear_layers)
        
        if self.bn:
            map(lambda bl: bl.dgamma.fill(0,0), self.bn_layers)
            map(lambda bl: bl.dbeta.fill(0,0), self.bn_layers)

    def step(self):
        if self.momentum == 0:
            for layer in self.linear_layers:
                layer.W = layer.W - self.lr * layer.dW
                layer.b = layer.b - self.lr * layer.db
        else:
            for layer in self.linear_layers:
                layer.momentum_W = self.momentum * layer.momentum_W - self.lr * layer.dW
                layer.W = layer.W + layer.momentum_W  
                layer.momentum_b = self.momentum * layer.momentum_b - self.lr * layer.db
                layer.b = layer.b + layer.momentum_b

        # Do the same for batchnorm layers
        if self.bn:
            for layer in self.bn_layers:
                layer.gamma = layer.gamma - self.lr * layer.dgamma
                layer.beta = layer.beta - self.lr * layer.dbeta

    def backward(self, labels):
        self.zero_grads()
        self.criterion(self.output, labels)
        delta = self.criterion.derivative()
        
        for l in reversed(range(self.nlayers)):
            delta = delta * self.activations[l].derivative()
            if self.bn and l < self.num_bn_layers:
                delta = self.bn_layers[l].backward(delta)
            delta = self.linear_layers[l].backward(delta)
                
    def error(self, labels):
        return (np.argmax(self.output, axis = 1) != np.argmax(labels, axis = 1)).sum()

    def total_loss(self, labels):
        return self.criterion(self.output, labels).sum()

    def __call__(self, x):
        return self.forward(x)

    def train(self):
        self.train_mode = True

    def eval(self):
        self.train_mode = False