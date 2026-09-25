# Multi-stage build para otimizar o tamanho da imagem

# Estágio 1: Build da aplicação
FROM maven:3.9-eclipse-temurin-17-alpine AS builder

WORKDIR /app

# Copia primeiro o pom.xml para aproveitar cache
COPY pom.xml .

# Baixa as dependências
RUN mvn dependency:go-offline -B

# Copia o código fonte
COPY src ./src

# Compila a aplicação
RUN mvn clean package -DskipTests


# Estágio 2: Imagem de runtime
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Cria usuário não-root
RUN addgroup -S spring && adduser -S spring -G spring

# Copia o JAR compilado
COPY --from=builder /app/target/*.jar app.jar

# Ajusta propriedade do arquivo
RUN chown spring:spring app.jar

USER spring:spring

EXPOSE 8080

ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]