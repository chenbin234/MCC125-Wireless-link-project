# Define a function to parse complex numbers from string
import torch
import numpy as np


import ast


def complex_parser(s):
    try:
        return ast.literal_eval(s)
    except (ValueError, SyntaxError):
        return s



def decoding_received_symbols(received_signal):

    