# Build stage
FROM node:18-alpine AS builder

# Install necessary build tools
RUN apk add --no-cache python3 make g++ git

# Create app directory
WORKDIR /usr/src/app

# Copy package files
COPY package.json ./
COPY tsconfig.json ./

# Install dependencies without running prepare script
RUN npm install --verbose --ignore-scripts

# Copy source code
COPY . .

# Install TypeScript globally
RUN npm install -g typescript@5.8.3

# Build the application manually
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /usr/src/app

# Copy built files from builder
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/package.json ./

# Install only production dependencies
RUN npm install --production --ignore-scripts

# Expose the port your app runs on
EXPOSE 3000

# Set default environment variables
ENV ES_URL="http://elasticsearch:9200"
ENV NODE_ENV="production"

# Start the application
CMD ["npm", "start"] 