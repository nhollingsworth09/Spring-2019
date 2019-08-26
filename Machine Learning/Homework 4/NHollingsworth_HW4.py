# -*- coding: utf-8 -*-

import numpy as np
from tensorflow.keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import Dropout
from keras.layers import Flatten
from keras.layers.convolutional import Conv2D
from keras.layers.convolutional import MaxPooling2D
from keras.utils import np_utils
from keras import backend as K
K.set_image_dim_ordering('th')

#%%
#################
#   Question 1
#################

# Part (b)

'''
f(x1,x2,x3) = (x2+3*x2*x1**2 - x1 + x3**2) - 4*x2*x1**2

'''

def y_value (x1,x2,x3):
    val = (x2+3*x2*x1**2-x1+2*x3**2)**2 - 4*x2*x1**2
    return val

def x1_deriv (x1, x2, x3):
    val = -8*x1*x2+2*(6*x1*x2-1)*(3*x2*x1**2-x1+x2+2*x3**2)
    return val

def x2_deriv (x1, x2, x3):
    val = -4*x1**2+2*(3*x1**2+1)*(3*x2*x1**2-x1+x2+2*x3**2)
    return val

def x3_deriv (x1, x2, x3):
    val = 8*x3*(3*x2*x1**2-x1+x2+2*x3**2) 
    return val

def find_minima (initial_x1, initial_x2, initial_x3, learning_rate):
    x1_current = initial_x1
    x2_current = initial_x2
    x3_current = initial_x3
    rate = learning_rate
    idx = 0
    
    while idx < 1000:        
        #-- Subtract a portion of the derivative with respect to Xi for correction (we subtract to go opposite direction of gradient)
        x1_current -= rate*x1_deriv(x1_current, x2_current, x3_current)
        x2_current -= rate*x2_deriv(x1_current, x2_current, x3_current)
        x3_current -= rate*x3_deriv(x1_current, x2_current, x3_current)
        
        idx += 1
        
    return print("Local Minimum occurs at ({}, {}, {})".format(round(x1_current,4), round(x2_current,4), round(x3_current,4)))

#-- (i)
find_minima(-3,-2,1,0.0002)
#-- (ii)
find_minima(1,1,1,0.005)

#%%
####################
#    Question 2
####################
np.random.seed(0)

(X_train, y_train), (X_test, y_test) = mnist.load_data()

X_train = X_train.reshape(X_train.shape[0], 1, 28, 28).astype('float32')
X_test = X_test.reshape(X_test.shape[0], 1, 28, 28).astype('float32')
X_train = X_train / 255
X_test = X_test / 255
y_train = np_utils.to_categorical(y_train)
y_test = np_utils.to_categorical(y_test)
num_classes = y_test.shape[1]

def larger_model():
    # create model
    model = Sequential()
    
    model.add(Conv2D(25, (7, 7), input_shape=(1, 28, 28), activation='relu'))
    model.add(MaxPooling2D(pool_size=(4, 4)))
    model.add(Dropout(0.25))
    model.add(Conv2D(15, (4, 4), activation='relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Dropout(0.25))
    model.add(Flatten())
    model.add(Dense(512, activation='relu'))
    model.add(Dense(196, activation='relu'))
    model.add(Dense(64, activation='relu'))
    model.add(Dense(num_classes, activation='softmax'))
    
    model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])
    return model

# Model defined
model = larger_model()
# Fit the model with 7 epochs
model.fit(X_train, y_train, validation_data=(X_test, y_test), epochs=7, batch_size=200)
# Final evaluation of the model
scores = model.evaluate(X_test, y_test, verbose=0)
print("Large CNN Error: %.2f%%" % (100-scores[1]*100))
