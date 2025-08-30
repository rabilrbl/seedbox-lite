/**
 * Environment Configuration
 * Provides centralized access to environment variables
 */

// Get API base URL from environment variables
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000';

// Remove trailing slash if present
const normalizeUrl = (url) => url.endsWith('/') ? url.slice(0, -1) : url;

export const config = {
  // API Configuration
  apiBaseUrl: normalizeUrl(API_BASE_URL),
  
  // Helper functions
  getApiUrl: (endpoint) => {
    const baseUrl = normalizeUrl(API_BASE_URL);
    
    // If baseUrl is just a path (like '/api'), handle endpoint correctly
    if (baseUrl.startsWith('/') && !baseUrl.startsWith('//')) {
      // Base URL is a relative path like '/api'
      // Remove leading '/api' from endpoint if it starts with '/api'
      if (endpoint.startsWith('/api/')) {
        endpoint = endpoint.substring(4); // Remove '/api' prefix
      } else if (endpoint.startsWith('api/')) {
        endpoint = endpoint.substring(3); // Remove 'api' prefix
      }
      return `${baseUrl}${endpoint.startsWith('/') ? endpoint : `/${endpoint}`}`;
    }
    
    // Base URL is a full URL (like 'http://localhost:3000')
    return `${baseUrl}${endpoint.startsWith('/') ? endpoint : `/${endpoint}`}`;
  },
  
  // API Endpoints (dynamic to use proper URL generation)
  get api() {
    return {
      torrents: config.getApiUrl('/api/torrents'),
      cache: config.getApiUrl('/api/cache'),
      system: config.getApiUrl('/api/system'),
    };
  },
  
  // Development helpers
  isDevelopment: import.meta.env.DEV,
  isProduction: import.meta.env.PROD,
  
  // Torrent API helpers
  getTorrentUrl: (infoHash, endpoint = '') => 
    config.getApiUrl(`/api/torrents/${infoHash}${endpoint ? `/${endpoint}` : ''}`),
    
  getStreamUrl: (infoHash, fileIndex) => 
    config.getApiUrl(`/api/torrents/${infoHash}/files/${fileIndex}/stream`),
    
  getDownloadUrl: (infoHash, fileIndex) => 
    config.getApiUrl(`/api/torrents/${infoHash}/files/${fileIndex}/download`),
};

// Log configuration in development
if (config.isDevelopment) {
  console.log('🔧 Environment Configuration:', {
    apiBaseUrl: config.apiBaseUrl,
    environment: config.isDevelopment ? 'development' : 'production'
  });
}
