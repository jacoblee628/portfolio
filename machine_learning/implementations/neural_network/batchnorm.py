import numpy as np

class BatchNorm(object):
    """ Batch Normalization Layer """

    def __init__(self, in_feature, alpha=0.9):
        self.alpha = alpha
        self.eps = 1e-8
        self.x = None
        self.norm = None
        self.out = None

        self.var = np.ones((1, in_feature))
        self.mean = np.zeros((1, in_feature))

        self.gamma = np.ones((1, in_feature))
        self.dgamma = np.zeros((1, in_feature))

        self.beta = np.zeros((1, in_feature))
        self.dbeta = np.zeros((1, in_feature))

        self.running_mean = np.zeros((1, in_feature))
        self.running_var = np.ones((1, in_feature))

    def __call__(self, x, eval=False):
        return self.forward(x, eval)

    def forward(self, x, eval=False):
        """
        Forward pass through batchnorm layer
        
        Argument:
            x (np.array): (batch_size, in_feature)
            eval (bool): inference status

        Return:
            out (np.array): (batch_size, in_feature)
        """
        self.x = x

        if not eval:
            self.mean = np.mean(self.x, axis=0, keepdims=True)
            self.var = np.var(self.x, axis=0, keepdims=True)
            self.norm = (self.x - self.mean) / np.sqrt(self.var + self.eps)

            self.running_mean = self.alpha * self.running_mean + (1 - self.alpha) * self.mean
            self.running_var = self.alpha * self.running_var + (1 - self.alpha) * self.var
        else:
            self.norm = (self.x - self.running_mean) / np.sqrt(self.running_var + self.eps)
            
        self.out = self.gamma * self.norm + self.beta
        return self.out


    def backward(self, delta):
        """
        Backwards pass through batchnorm layer
        
        Argument:
            delta (np.array): (batch size, in feature)
        Return:
            out (np.array): (batch size, in feature)
        """
        n, d = delta.shape
        dxhat = delta * self.gamma # outputs (1 x in_feature)
        x_mu = self.x - self.mean
        inv_var = 1.0 / np.sqrt(self.var + self.eps)
        dvar_B = np.sum(dxhat * x_mu * (-0.5) * (inv_var ** 3), axis=0)
        dmu_B = np.sum(dxhat * (- inv_var), axis=0) + dvar_B * (-2.0 / n) * np.sum(x_mu, axis=0)
        dL_x = (dxhat * inv_var) + dvar_B * (2.0 / self.x.shape[0]) * x_mu + (1.0 / self.x.shape[0]) * dmu_B
        
        self.dgamma = np.sum(self.norm * delta, axis=0, keepdims=True) # (1 x in_feature)
        self.dbeta = np.sum(delta, axis=0, keepdims=True) # (1 x in_feature)
        
        return dL_x