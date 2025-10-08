import React, { useState, useRef, useEffect } from 'react';
import axios from 'axios';
import Plot from 'react-plotly.js';
import './App.css';

// Componente para upload de arquivo
const FileUpload = ({ onFileUpload, isUploading }) => {
  const [dragActive, setDragActive] = useState(false);
  const fileInputRef = useRef(null);

  const handleDrag = (e) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.type === "dragenter" || e.type === "dragover") {
      setDragActive(true);
    } else if (e.type === "dragleave") {
      setDragActive(false);
    }
  };

  const handleDrop = (e) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      onFileUpload(e.dataTransfer.files[0]);
    }
  };

  const handleChange = (e) => {
    e.preventDefault();
    if (e.target.files && e.target.files[0]) {
      onFileUpload(e.target.files[0]);
    }
  };

  return (
    <div className="mb-6">
      <div
        className={`relative border-2 border-dashed rounded-lg p-6 text-center cursor-pointer transition-colors ${
          dragActive 
            ? 'border-blue-400 bg-blue-50' 
            : 'border-gray-300 hover:border-gray-400'
        } ${isUploading ? 'opacity-50 cursor-not-allowed' : ''}`}
        onDragEnter={handleDrag}
        onDragLeave={handleDrag}
        onDragOver={handleDrag}
        onDrop={handleDrop}
        onClick={() => !isUploading && fileInputRef.current.click()}
      >
        <input
          ref={fileInputRef}
          type="file"
          accept=".csv"
          onChange={handleChange}
          className="hidden"
          disabled={isUploading}
        />
        <div className="space-y-2">
          <i className="fas fa-cloud-upload-alt text-4xl text-gray-400"></i>
          <div>
            <p className="text-lg font-medium text-gray-700">
              {isUploading ? 'Carregando arquivo...' : 'Clique ou arraste seu arquivo CSV aqui'}
            </p>
            <p className="text-sm text-gray-500">
              Suporta apenas arquivos .csv
            </p>
          </div>
        </div>
        {isUploading && (
          <div className="absolute inset-0 flex items-center justify-center bg-white bg-opacity-75">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          </div>
        )}
      </div>
    </div>
  );
};

// Componente para exibir insights
const InsightsDisplay = ({ insights }) => {
  if (!insights || insights.length === 0) return null;
  
  return (
    <div className="insights-container mb-4">
      <h4 className="text-sm font-medium text-gray-700 mb-2">💡 Insights Automáticos</h4>
      <div className="space-y-2">
        {insights.map((insight, index) => (
          <div key={index} className="bg-blue-50 border-l-4 border-blue-400 p-3 rounded">
            <p className="text-sm text-gray-700">{insight}</p>
          </div>
        ))}
      </div>
    </div>
  );
};

// Componente para exibir gráficos
const ChartDisplay = ({ chart }) => {
  if (!chart || !chart.data) return null;
  
  console.log('Chart data:', chart); // Debug
  
  return (
    <div className="chart-container mb-4">
      <h4 className="text-sm font-medium text-gray-700 mb-2">{chart.title}</h4>
      <div className="bg-white p-4 rounded-lg shadow-sm border">
        <Plot
          data={[chart.data]}
          layout={{
            ...chart.layout,
            autosize: true,
            margin: { l: 50, r: 50, t: 50, b: 50 }
          }}
          style={{ width: '100%', height: '400px' }}
          config={{
            displayModeBar: true,
            displaylogo: false,
            responsive: true,
            modeBarButtonsToRemove: ['pan2d', 'lasso2d', 'select2d']
          }}
        />
      </div>
    </div>
  );
};

// Componente principal da mensagem
const MessageBubble = ({ message, isUser }) => {
  return (
    <div className={`flex ${isUser ? 'justify-end' : 'justify-start'} mb-4 fade-in`}>
      <div className={`message-bubble px-4 py-2 rounded-lg ${
        isUser 
          ? 'user-message text-white' 
          : 'assistant-message text-white'
      }`}>
        <div className="whitespace-pre-wrap">{message.content}</div>
        {message.insights && message.insights.length > 0 && (
          <div className="mt-3">
            <InsightsDisplay insights={message.insights} />
          </div>
        )}
        {message.charts && message.charts.length > 0 && (
          <div className="mt-3 space-y-3">
            {message.charts.map((chart, index) => (
              <ChartDisplay key={index} chart={chart} />
            ))}
          </div>
        )}
        <div className="text-xs opacity-75 mt-1">
          {new Date(message.timestamp).toLocaleTimeString('pt-BR')}
        </div>
      </div>
    </div>
  );
};

// Componente de sugestões de perguntas
const QuestionSuggestions = ({ onQuestionSelect, datasetInfo }) => {
  const suggestions = [
    "Faça uma análise geral do dataset",
    "Quais são as estatísticas básicas dos dados?",
    "Existem outliers nos dados?",
    "Mostre a correlação entre as variáveis",
    "Qual a distribuição das variáveis numéricas?",
    "Identifique padrões interessantes nos dados"
  ];

  // Sugestões específicas baseadas no dataset
  const specificSuggestions = [];
  if (datasetInfo?.numeric_columns) {
    specificSuggestions.push(`Analise a distribuição de ${datasetInfo.numeric_columns[0]}`);
  }
  if (datasetInfo?.categorical_columns && datasetInfo.categorical_columns.length > 0) {
    specificSuggestions.push(`Analise a variável categórica ${datasetInfo.categorical_columns[0]}`);
  }

  const allSuggestions = [...suggestions, ...specificSuggestions];

  return (
    <div className="mb-4">
      <h3 className="text-sm font-medium text-gray-700 mb-2">Sugestões de perguntas:</h3>
      <div className="flex flex-wrap gap-2">
        {allSuggestions.slice(0, 6).map((suggestion, index) => (
          <button
            key={index}
            onClick={() => onQuestionSelect(suggestion)}
            className="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-sm hover:bg-blue-200 transition-colors"
          >
            {suggestion}
          </button>
        ))}
      </div>
    </div>
  );
};

// Componente principal
function App() {
  const [sessionId, setSessionId] = useState(null);
  const [datasetInfo, setDatasetInfo] = useState(null);
  const [messages, setMessages] = useState([]);
  const [currentMessage, setCurrentMessage] = useState('');
  const [isUploading, setIsUploading] = useState(false);
  const [isSending, setIsSending] = useState(false);
  const [error, setError] = useState(null);
  const chatContainerRef = useRef(null);

  // Configurar axios base URL
  // IMPORTANTE: Prioriza REACT_APP_BACKEND_URL para usar backend separado
  const apiUrl = process.env.REACT_APP_BACKEND_URL || 
    (process.env.NODE_ENV === 'production' 
      ? window.location.origin 
      : 'http://localhost:8000');
  axios.defaults.baseURL = apiUrl;

  // Log de configuração (útil para debug)
  useEffect(() => {
    console.log('🔧 Configuração da Aplicação:');
    console.log('  - Ambiente:', process.env.NODE_ENV);
    console.log('  - API URL:', apiUrl);
    console.log('  - Origin:', window.location.origin);
    console.log('  - Backend URL:', process.env.REACT_APP_BACKEND_URL || 'não definida');
  }, [apiUrl]);

  // Scroll automático para o final do chat
  useEffect(() => {
    if (chatContainerRef.current) {
      chatContainerRef.current.scrollTop = chatContainerRef.current.scrollHeight;
    }
  }, [messages]);

  // Função para upload de arquivo
  const handleFileUpload = async (file) => {
    console.log('📤 Iniciando upload do arquivo:', file.name);
    console.log('📏 Tamanho:', (file.size / 1024).toFixed(2), 'KB');
    
    setIsUploading(true);
    setError(null);
    
    try {
      const formData = new FormData();
      formData.append('file', file);
      
      console.log('🚀 Enviando requisição para:', `${apiUrl}/api/upload-csv`);

      const response = await axios.post('/api/upload-csv', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      console.log('✅ Upload bem-sucedido:', response.data);

      setSessionId(response.data.session_id);
      setDatasetInfo(response.data.basic_info);
      
      // Adicionar mensagem inicial do sistema
      const initialMessage = {
        content: `📊 Dataset carregado com sucesso!\n\n${response.data.message}\n\n${response.data.initial_analysis}`,
        timestamp: new Date(),
        isUser: false,
        insights: response.data.insights || []
      };
      
      setMessages([initialMessage]);
      
    } catch (err) {
      console.error('❌ Erro no upload:', err);
      console.error('❌ Status:', err.response?.status);
      console.error('❌ Dados do erro:', err.response?.data);
      console.error('❌ Headers:', err.response?.headers);
      
      const errorMessage = err.response?.data?.detail || 
                          err.message || 
                          'Erro ao carregar arquivo';
      setError(errorMessage);
    } finally {
      setIsUploading(false);
    }
  };

  // Função para enviar mensagem
  const handleSendMessage = async (message = currentMessage) => {
    if (!message.trim() || !sessionId || isSending) return;

    console.log('💬 Enviando mensagem:', message);

    const userMessage = {
      content: message,
      timestamp: new Date(),
      isUser: true
    };

    setMessages(prev => [...prev, userMessage]);
    setCurrentMessage('');
    setIsSending(true);
    setError(null);

    try {
      console.log('🚀 Requisição para:', `${apiUrl}/api/chat`);
      
      const response = await axios.post('/api/chat', {
        message: message,
        session_id: sessionId
      });

      console.log('✅ Resposta recebida:', response.data);

      const assistantMessage = {
        content: response.data.response,
        timestamp: new Date(),
        isUser: false,
        insights: response.data.insights || [],
        charts: response.data.charts || []
      };

      setMessages(prev => [...prev, assistantMessage]);

    } catch (err) {
      console.error('❌ Erro no chat:', err);
      console.error('❌ Status:', err.response?.status);
      console.error('❌ Dados do erro:', err.response?.data);
      
      const errorDetail = err.response?.data?.detail || 'Erro ao processar mensagem';
      setError(errorDetail);
      
      const errorMessage = {
        content: `❌ Erro: ${errorDetail}`,
        timestamp: new Date(),
        isUser: false,
        insights: [],
        charts: []
      };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setIsSending(false);
    }
  };

  // Função para selecionar pergunta sugerida
  const handleQuestionSelect = (question) => {
    setCurrentMessage(question);
    handleSendMessage(question);
  };

  // Função para reiniciar sessão
  const handleRestart = () => {
    setSessionId(null);
    setDatasetInfo(null);
    setMessages([]);
    setCurrentMessage('');
    setError(null);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="container mx-auto px-4 py-8">
        {/* Header */}
        <header className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-800 mb-2">
            🤖 Agente de Análise Exploratória de Dados
          </h1>
          <p className="text-lg text-gray-600">
            Agente inteligente para análise de arquivos CSV com IA
          </p>
        </header>

        {/* Error Display */}
        {error && (
          <div className="mb-6 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg">
            <div className="flex items-center">
              <i className="fas fa-exclamation-triangle mr-2"></i>
              {error}
            </div>
          </div>
        )}

        {/* Main Content */}
        <div className="max-w-4xl mx-auto">
          {!sessionId ? (
            // Upload Section
            <div className="bg-white rounded-lg shadow-lg p-6">
              <h2 className="text-2xl font-semibold text-gray-800 mb-4">
                📁 Carregue seu arquivo CSV
              </h2>
              <FileUpload onFileUpload={handleFileUpload} isUploading={isUploading} />
              
              <div className="mt-6 p-4 bg-blue-50 rounded-lg">
                <h3 className="font-medium text-blue-800 mb-2">💡 O que este agente pode fazer:</h3>
                <ul className="text-sm text-blue-700 space-y-1">
                  <li>• Análise estatística completa dos seus dados</li>
                  <li>• Detecção automática de outliers e anomalias</li>
                  <li>• Geração de gráficos e visualizações interativas</li>
                  <li>• Análise de correlações entre variáveis</li>
                  <li>• Identificação de padrões e tendências</li>
                  <li>• Conclusões inteligentes baseadas nos dados</li>
                </ul>
              </div>
            </div>
          ) : (
            // Chat Interface
            <div className="bg-white rounded-lg shadow-lg overflow-hidden">
              {/* Dataset Info Header */}
              <div className="bg-gradient-to-r from-blue-600 to-purple-600 text-white p-4">
                <div className="flex justify-between items-center">
                  <div>
                    <h2 className="text-xl font-semibold">
                      📊 Dataset Carregado
                    </h2>
                    <p className="text-blue-100 text-sm">
                      {datasetInfo?.shape?.[0]} linhas × {datasetInfo?.shape?.[1]} colunas
                    </p>
                  </div>
                  <button
                    onClick={handleRestart}
                    className="px-4 py-2 bg-white bg-opacity-20 rounded-lg hover:bg-opacity-30 transition-colors"
                  >
                    <i className="fas fa-refresh mr-2"></i>
                    Novo Dataset
                  </button>
                </div>
              </div>

              {/* Question Suggestions */}
              {messages.length <= 1 && (
                <div className="p-4 bg-gray-50 border-b">
                  <QuestionSuggestions 
                    onQuestionSelect={handleQuestionSelect}
                    datasetInfo={datasetInfo}
                  />
                </div>
              )}

              {/* Chat Messages */}
              <div 
                ref={chatContainerRef}
                className="chat-container p-4 space-y-4"
                style={{ maxHeight: '500px' }}
              >
                {messages.map((message, index) => (
                  <MessageBubble
                    key={index}
                    message={message}
                    isUser={message.isUser}
                  />
                ))}
                
                {isSending && (
                  <div className="flex justify-start mb-4">
                    <div className="bg-gray-200 px-4 py-2 rounded-lg">
                      <div className="flex items-center space-x-2">
                        <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-gray-600"></div>
                        <span className="text-gray-600">Analisando...</span>
                      </div>
                    </div>
                  </div>
                )}
              </div>

              {/* Message Input */}
              <div className="p-4 border-t bg-gray-50">
                <div className="flex space-x-2">
                  <input
                    type="text"
                    value={currentMessage}
                    onChange={(e) => setCurrentMessage(e.target.value)}
                    onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
                    placeholder="Digite sua pergunta sobre os dados..."
                    className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    disabled={isSending}
                  />
                  <button
                    onClick={() => handleSendMessage()}
                    disabled={!currentMessage.trim() || isSending}
                    className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                  >
                    <i className="fas fa-paper-plane"></i>
                  </button>
                </div>
                <div className="mt-2 text-xs text-gray-500">
                  Pressione Enter para enviar • Exemplos: "Faça uma análise geral", "Mostre correlações", "Detecte outliers"
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <footer className="mt-8 text-center text-sm text-gray-500">
          <p>
            Desenvolvido Fernando Meregali Xavier • 
            Tecnologias: FastAPI, React, Groq LLM-> deepseek-r1-distill-llama-70b, MongoDB
          </p>
        </footer>
      </div>
    </div>
  );
}

export default App;
