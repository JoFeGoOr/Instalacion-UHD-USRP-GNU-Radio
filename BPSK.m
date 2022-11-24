clear
clc


M = 2;                 % Modulation alphabet
k = log2(M);           % Bits/symbol
numSC = 52;            % Number of OFDM subcarriers
cpLen = 16;            % OFDM cyclic prefix length
maxBitErrors = 100;    % Maximum number of bit errors
maxNumBits = 1e7;      % Maximum number of bits transmitted

ofdmMod = comm.OFDMModulator('FFTLength',numSC,'CyclicPrefixLength',cpLen);
ofdmDims = info(ofdmMod);
numDC = ofdmDims.DataInputSize(1);

EbNoVec = (0:10)';
snrVec = EbNoVec + 10*log10(k) + 10*log10(numDC/numSC);

berTheory = berawgn(EbNoVec,'psk',M,'nondiff');

exp = [];


figure
semilogy(EbNoVec,berTheory,'Color','Red')
hold on
for m = 1:size(exp,1)
    semilogy(EbNoVec,exp(m,:),'*','Color','blue')
end
for m = 1:size(gnu,1)
    semilogy(EbNoVec,gnu(m,:),'+','Color','Green')
end
legend('Teoria','Simulacion Matlab','','','','','','','','','','Simulacion GNU')
xlabel('Eb/No (dB)')
ylabel('Bit Error Rate')
grid on
hold off