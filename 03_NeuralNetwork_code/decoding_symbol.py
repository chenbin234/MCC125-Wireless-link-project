# Define a function to parse complex numbers from string
import torch
import numpy as np
import model_Transformer_modified
import os
import model_LSTM


def matrix_to_complex_vector(A):

    # Use squeeze to remove the first dimension
    reshaped_A = A.squeeze(0).numpy().transpose()

    # Extract the real and imaginary parts
    real_part = reshaped_A[0, :]
    imag_part = reshaped_A[1, :]

    # Combine real and imaginary parts to create a complex vector
    complex_vector = real_part + 1j * imag_part

    return complex_vector


def decoding_symbol(received_signal):

    # lenght of sequence given to encoder
    gt = 495
    # length of sequence given to decoder
    horizon = 15
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

    # convert a complex number vector to a 2-D matrix
    real_received_symbol = np.real(received_signal)
    imag_received_symbol = np.imag(received_signal)

    received_matrix = np.array(
        [real_received_symbol, imag_received_symbol]).transpose(1, 2, 0)
    # received_matrix = np.column_stack((real_received_symbol, imag_received_symbol))

    # Convert NumPy array to PyTorch tensor
    received_matrix = torch.tensor(received_matrix)

    # load the pretrained model
    # defining model save location
    # save_location = "./Transformer_models"
    # device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    # loaded_file = torch.load(os.path.join(
    #     save_location, 'Transformer_based_channel_model_fsfd3_epoch50.pth'), map_location=torch.device(device))

    # model_loaded = model_Transformer_modified.Transformer(encoder_input_size=2, decoder_input_size=2,
    #                                                       embedding_size=32, num_heads=4, num_layers=6, feedforward_size=1024).to(device)

    # load the LSTM model
    # defining model save location
    save_location = "./LSTM_models"
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    loaded_file = torch.load(os.path.join(
        save_location, 'Channel_model_LSTM_epoch31.pth'), map_location=torch.device(device))

    model_loaded = model_LSTM.LSTM(input_size=2, input_seq_len=475,
                                   hidden_size=128, num_layers=3, output_size=2, output_seq_len=15).to(device)

    model_loaded = model_loaded.to(device)
    model_loaded.load_state_dict(loaded_file['model_state_dict'])

    # generate prediction on received symbols
    with torch.no_grad():

        # EVALUATION MODE
        model_loaded.eval()

        # # input to decoder
        # start_of_seq = torch.Tensor([0, 1]).unsqueeze(
        #     0).unsqueeze(1).repeat(1, 1, 1).to(device)
        # dec_input = start_of_seq

        # # predict untill horizon length
        # for i in range(horizon):

        #     model_output = model_loaded.forward(received_matrix, dec_input)

        #     # appending the predicition to decoder input for next cycle
        #     dec_input = torch.cat((dec_input, model_output[:, -1:, :]), 1)
        model_output = model_loaded.forward(received_matrix)

    # convert the dec_inp to a complex number vector
    decoded_symbols = matrix_to_complex_vector(model_output[:, 1:])

    return decoded_symbols


# np.random.seed(42)

# # Generate a vector of length 150 with random complex numbers
random_complex_vector = np.array([np.random.rand(475) + 1j * np.random.rand(475)])

decoded_symbols = decoding_symbol(random_complex_vector)

print(decoded_symbols)
