PRAGMA foreign_keys = ON;

-- ============================================
-- TABELA: INSTITUICAO
-- ============================================
CREATE TABLE Instituicao (
    idInstituicao       INTEGER PRIMARY KEY AUTOINCREMENT,
    nomeInstituicao     TEXT NOT NULL,
    cnpj                TEXT UNIQUE,
    enderecoFisico      TEXT,
    enderecoEletronico  TEXT,
    telefone            TEXT
);

-- ============================================
-- TABELA: USUARIO
-- ============================================
CREATE TABLE Usuario (
    idUsuario            INTEGER PRIMARY KEY AUTOINCREMENT,
    nomeCompleto         TEXT NOT NULL,
    email                TEXT UNIQUE NOT NULL,
    senhaHash            TEXT NOT NULL,
    registroProfissional TEXT,
    profissao            TEXT,
    ativo                INTEGER DEFAULT 1,
    perfil               TEXT NOT NULL DEFAULT 'MEDICO',
    idInstituicao        INTEGER NOT NULL,

    CHECK (perfil IN ('MEDICO', 'TECNICO', 'ADMIN', 'AUDITOR')),

    FOREIGN KEY (idInstituicao)
        REFERENCES Instituicao(idInstituicao)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ============================================
-- TABELA: IMAGEM_EXAME
-- ============================================
CREATE TABLE ImagemExame (
    idImagem        INTEGER PRIMARY KEY AUTOINCREMENT,
    idUsuario       INTEGER NOT NULL,
    idInstituicao   INTEGER NOT NULL,
    caminhoArquivo  TEXT NOT NULL,
    dataUpload      TEXT DEFAULT CURRENT_TIMESTAMP,
    descricaoOpcional TEXT,
    tipoImagem      TEXT,

    FOREIGN KEY (idUsuario)
        REFERENCES Usuario(idUsuario)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (idInstituicao)
        REFERENCES Instituicao(idInstituicao)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ============================================
-- TABELA: ANALISE_IMAGEM
-- ============================================
CREATE TABLE AnaliseImagem (
    idAnalise            INTEGER PRIMARY KEY AUTOINCREMENT,
    idImagem             INTEGER NOT NULL,
    idUsuarioSolicitante INTEGER,
    dataHoraSolicitacao  TEXT NOT NULL,
    dataHoraConclusao    TEXT,
    resultadoClassificacao TEXT NOT NULL,
    scoreConfianca       REAL,
    modeloVersao         TEXT,
    modeloChecksum       TEXT,
    hashImagem           TEXT,

    CHECK (resultadoClassificacao IN ('Maligno','Benigno','Cisto','Saudável')),

    FOREIGN KEY (idImagem)
        REFERENCES ImagemExame(idImagem)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (idUsuarioSolicitante)
        REFERENCES Usuario(idUsuario)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ============================================
-- TABELA: LAUDO
-- ============================================
CREATE TABLE Laudo (
    idLaudo               INTEGER PRIMARY KEY AUTOINCREMENT,
    idAnalise             INTEGER UNIQUE NOT NULL,
    idUsuarioResponsavel  INTEGER,
    dataHoraEmissao       TEXT DEFAULT CURRENT_TIMESTAMP,
    textoLaudoCompleto    TEXT NOT NULL,
    caminhoPDF            TEXT,
    confirmouConcordancia INTEGER NOT NULL,
    ipEmissao             TEXT,
    laudoFinalizado       INTEGER DEFAULT 0,
    codigoVerificacao     TEXT UNIQUE,

    FOREIGN KEY (idAnalise)
        REFERENCES AnaliseImagem(idAnalise)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (idUsuarioResponsavel)
        REFERENCES Usuario(idUsuario)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ============================================
-- TABELA: LOG_AUDITORIA
-- ============================================
CREATE TABLE LogAuditoria (
    idLog      INTEGER PRIMARY KEY AUTOINCREMENT,
    idUsuario  INTEGER,
    dataHora   TEXT DEFAULT CURRENT_TIMESTAMP,
    acao       TEXT NOT NULL,
    recurso    TEXT,
    detalhe    TEXT,
    ipOrigem   TEXT,
    protegido  INTEGER DEFAULT 1,

    CHECK (acao IN (
        'LOGIN_SUCESSO', 'LOGIN_FALHA', 'LOGOUT', 'UPLOAD_IMAGEM',
        'ANALISE_SOLICITADA', 'ANALISE_CONCLUIDA', 'LAUDO_GERADO',
        'LAUDO_IMPRESSO', 'LAUDO_ALTERADO', 'LAUDO_VERSIONADO',
        'ERRO_SISTEMA'
    )),

    FOREIGN KEY (idUsuario)
        REFERENCES Usuario(idUsuario)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ============================================
-- TABELA: HISTORICO_LAUDO
-- ============================================
CREATE TABLE HistoricoLaudo (
    idHistorico          INTEGER PRIMARY KEY AUTOINCREMENT,
    idLaudo              INTEGER NOT NULL,
    idUsuarioResponsavel INTEGER NOT NULL,
    dataHoraAlteracao    TEXT DEFAULT CURRENT_TIMESTAMP,
    textoAnterior        TEXT NOT NULL,
    ipAlteracao          TEXT,

    FOREIGN KEY (idLaudo)
        REFERENCES Laudo(idLaudo)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (idUsuarioResponsavel)
        REFERENCES Usuario(idUsuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ============================================
-- TABELA: LAUDO_IMPRESSAO
-- ============================================
CREATE TABLE LaudoImpressao (
    idImpressao INTEGER PRIMARY KEY AUTOINCREMENT,
    idLaudo     INTEGER NOT NULL,
    idUsuario   INTEGER NOT NULL,
    dataHoraImpressao TEXT DEFAULT CURRENT_TIMESTAMP,
    ipOrigem    TEXT,
    localImpressao TEXT,

    FOREIGN KEY (idLaudo)
        REFERENCES Laudo(idLaudo)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (idUsuario)
        REFERENCES Usuario(idUsuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
