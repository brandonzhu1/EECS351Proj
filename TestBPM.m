%Enter .wav file of choice:

%Full credit to Eng Eder de Souza and George Tzanetakis.

%Note: It works much better with stationary BPM that are established early
%on. The original algorithm only scanned over the first 3 seconds for
%efficiency. This one works for the entire length, but does significantly
%downsample the signal.

%Enter filename here
filename = 'AudioTest_B128.wav';
BPM = RunBPM(filename);

function [BPM]=RunBPM(AudioFile)

%Code adapted from Eder de Souza GitHub and Tzanatakis Paper. 

[Signal,Fs]=audioread(AudioFile);

%Can specify either channel for stereo audio.

Signal = Signal(:,1);

%Instantiate range for BPM "search"
MinBPM=40;
MaxBPM=200;

new_fs = 22050;
EnvelopeDecimated=250;

%Utilize corresponding SubBandDWT function to split the octaves of the
%original audio signal.

[SubBand1, numerator1, denominator1]=SubBandDWT(Signal,Fs,1,200);

[SubBand2, numerator2, denominator2]=SubBandDWT(Signal,Fs,200,400);

[SubBand3, numerator3, denominator3]=SubBandDWT(Signal,Fs,400,800);

[SubBand4, numerator4, denominator4]=SubBandDWT(Signal,Fs,800,1600);

[SubBand5, numerator5, denominator5]=SubBandDWT(Signal,Fs,1600,3200);

[SubBand6, numerator6, denominator6]=SubBandDWT(Signal,Fs,3200,6400);


DecimateValue = ceil(Fs/new_fs);

%Generate octave envelopes:

Envelope1=Envelope(SubBand1, DecimateValue, new_fs, numerator1, denominator1);

Envelope2=Envelope(SubBand2, DecimateValue, new_fs, numerator2, denominator2);

Envelope3=Envelope(SubBand3, DecimateValue, new_fs, numerator3, denominator3);

Envelope4=Envelope(SubBand4, DecimateValue, new_fs, numerator4, denominator4);

Envelope5=Envelope(SubBand5, DecimateValue, new_fs, numerator5, denominator5);

Envelope6=Envelope(SubBand6, DecimateValue, new_fs, numerator6, denominator6);


%Reduce samples to allow for more efficient autocorrelation:

EnvelopeDecimated1=Envelope1(1:floor((Fs/DecimateValue)/EnvelopeDecimated):length(Envelope1));
EnvelopeDecimated2=Envelope2(1:floor((Fs/DecimateValue)/EnvelopeDecimated):length(Envelope2));
EnvelopeDecimated3=Envelope3(1:floor((Fs/DecimateValue)/EnvelopeDecimated):length(Envelope3));
EnvelopeDecimated4=Envelope4(1:floor((Fs/DecimateValue)/EnvelopeDecimated):length(Envelope4));
EnvelopeDecimated5=Envelope5(1:floor((Fs/DecimateValue)/EnvelopeDecimated):length(Envelope5));
EnvelopeDecimated6=Envelope5(1:floor((Fs/DecimateValue)/EnvelopeDecimated):length(Envelope6));

%Recombine envelopes
SumEnvelope = EnvelopeDecimated1 + EnvelopeDecimated2 + EnvelopeDecimated3 + EnvelopeDecimated4 + EnvelopeDecimated5 + EnvelopeDecimated6;


%Autocorrelation on envelopes
CorrelationEnvelope=AutoCorrelation(SumEnvelope,EnvelopeDecimated,MinBPM,MaxBPM);

%Find maximum autocorrelation peak:
[max_strength, max_pos]=max(CorrelationEnvelope);

%Convert peak to BPM:
BPM=60*EnvelopeDecimated/(max_pos);
end


function [SubBand, numerator, denominator]=SubBandDWT(Signal,Fs,L,H)

%Code adapted from Eder de Souza GitHub and Tzanatakis Paper. 

%Normalize the Low Frequency Band
LowFrequencyBand = L/(Fs/2);

%Creating the highpass filter coefficient
[numerator,denominator] = butter(2, LowFrequencyBand, 'high');

%Apply highpass filter in the signal wave
FiltredSignal = filtfilt(numerator, denominator, Signal);

%Normalize the High Frequency Band
HighFrequencyBand = H/(Fs/2);

%Creating the lowpass filter coefficient
[numerator,denominator] = butter(2, HighFrequencyBand, 'low');

%Apply Lowpass filter in the FiltredSignal
SubBand = filtfilt(numerator, denominator, FiltredSignal);
end

  
function [RectifiedEnvelope]=Envelope(SubBand,DecimateValue,new_fs,numerator,denominator)

%Code adapted from Eder de Souza GitHub and Tzanatakis Paper. 

%Step 1: Full-Wave Rectification
SubBand = abs(SubBand);

%Step 2: LPF
LowPassSubBand = filtfilt(numerator, denominator, SubBand);

%Step 3: Downsample
bands = downsample(LowPassSubBand, DecimateValue);

%Step 4: Mean Removal
MeanRemoval=bands-mean(bands);


Tw = 0.1;
Nw=Tw*new_fs;
w=ones(Nw,1)/Nw;     

RectifiedEnvelope=conv((MeanRemoval),w,'same');

end

function [Xcorre]=AutoCorrelation(ENVELOPE,EnvelopeDecimated,MinBPM,MaxBPM)

%Code adapted from Eder de Souza GitHub and Tzanetakis Paper. 

EndPosition = ceil((60 * EnvelopeDecimated) / (MinBPM));

StartPosition = ceil((60 * EnvelopeDecimated) / (MaxBPM));

TotalSamples = length(ENVELOPE) - EndPosition;

Xcorre = zeros(EndPosition,1);

for pos=StartPosition:EndPosition
	sum = 0;
	for i=1:TotalSamples
		sum = sum + (ENVELOPE(i)*ENVELOPE(i + pos));
	end
	Xcorre(pos) = Xcorre(pos) + sum;
end

end
