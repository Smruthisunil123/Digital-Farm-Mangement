import os
from langchain_community.document_loaders import DirectoryLoader, TextLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import OllamaEmbeddings

# Define the paths
KNOWLEDGE_BASE_DIR = "knowledge_base"
DB_DIR = "vector_db"

def main():
    print("Starting ingestion process...")
    
    # 1. Load all documents from the knowledge base folder
    print(f"Loading documents from {KNOWLEDGE_BASE_DIR}...")
    
    # ✅ THE FIX: The correct argument name is 'loader_cls' (short for class)
    loader = DirectoryLoader(
        KNOWLEDGE_BASE_DIR,
        glob="**/*.txt", # Load only .txt files
        loader_cls=TextLoader,
        show_progress=True,
        use_multithreading=True
    )
    documents = loader.load()
    print(f"Loaded {len(documents)} documents.")

    # 2. Split the documents into smaller chunks
    print("Splitting documents into chunks...")
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=1000, 
        chunk_overlap=200
    )
    chunks = text_splitter.split_documents(documents)
    print(f"Split into {len(chunks)} chunks.")

    # 3. Initialize the embedding model (the "reading" model)
    print("Initializing embedding model (mxbai-embed-large)...")
    embeddings = OllamaEmbeddings(model="mxbai-embed-large")

    # 4. Create the vector database and store the chunks
    print(f"Creating and persisting vector database in '{DB_DIR}'...")
    db = Chroma.from_documents(
        chunks, 
        embeddings, 
        persist_directory=DB_DIR
    )
    
    print("\n--- Ingestion Complete ---")
    print(f"Your AI 'memory' is now saved in the '{DB_DIR}' folder.")

if __name__ == "__main__":
    main()