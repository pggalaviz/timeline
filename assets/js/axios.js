// libs
import axios from 'axios'

// Set axios instantce configuration
const HTTP = axios.create({
  baseURL: '/api',
  timeout: 5000,
  withCredentials: true,
  headers: {
    Accept: 'application/json',
    'Content-Type': 'application/json; charset=UTF-8'
    // 'X-Requested-With': 'Browser'
  }
})

// =======
// Request
// =======

HTTP.interceptors.request.use((config) => {
  return config
}, (err) => {
  throw err
})

// ========
// Response
// ========

HTTP.interceptors.response.use((response) => {
  return response
}, (err) => {
  // A response was sent by the server.
  if (err.response) {
    // Return the just the Response
    throw err.response
  }
  // The request was made but no server response was received
  if (err.request) {
    throw err.request
  }
  // Throw any other error
  throw err
})

export default {
  post (url, data = {}) {
    return HTTP({
      method: 'post',
      url: url,
      data
    })
  },
  get (url, params) {
    return HTTP({
      method: 'get',
      url: url,
      params
    })
  },
  delete (url, params) {
    return HTTP({
      method: 'delete',
      url: url,
      params
    })
  },
  put (url, data) {
    return HTTP({
      method: 'put',
      url: url,
      data
    })
  }
}
