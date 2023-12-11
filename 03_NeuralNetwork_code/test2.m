% % 5. call the pretrained neural network
% a = py.numpy.array([1+2i,2+3i])
% b = py.numpy.array([3+4i,5+6i])
% 
% result = py.add.add(a,b)
% 
% convert_result = double(result)

pyenv(Version="/opt/homebrew/bin/python3.10")

pe = pyenv;

if isempty(pe.Version)
    disp "Python not installed"
end
