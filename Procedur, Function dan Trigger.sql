-- 1. LATIHAN KONDISIONAL: Prosedur cek_kelulusan
-- Mengevaluasi kelulusan jika rata-rata >= 75
DELIMITER //

CREATE PROCEDURE cek_kelulusan(
    IN p_id_mahasiswa INT,
    OUT p_status VARCHAR(20)
)
BEGIN
    DECLARE v_rata_rata DECIMAL(5,2);

    -- Menghitung rata-rata nilai mahasiswa
    SELECT AVG(nilai) INTO v_rata_rata
    FROM nilai
    WHERE id_mahasiswa = p_id_mahasiswa;

    -- Evaluasi kelulusan
    IF v_rata_rata >= 75 THEN
        SET p_status = 'LULUS';
    ELSE
        SET p_status = 'TIDAK LULUS';
    END IF;
END //

DELIMITER ;


-- 2. LATIHAN LOOPING: Prosedur total_nilai_semua_mahasiswa
-- Menghitung total seluruh nilai menggunakan loop (CURSOR)
DELIMITER //

CREATE PROCEDURE total_nilai_semua_mahasiswa(
    OUT p_total_seluruh INT
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_nilai INT;
    -- Mendeklarasikan kursor untuk mengambil semua data nilai
    DECLARE cur_nilai CURSOR FOR SELECT nilai FROM nilai;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET p_total_seluruh = 0;

    OPEN cur_nilai;

    read_loop: LOOP
        FETCH cur_nilai INTO v_nilai;
        IF done THEN
            LEAVE read_loop;
        END IF;
        -- Menambahkan nilai ke dalam variabel total
        SET p_total_seluruh = p_total_seluruh + v_nilai;
    END LOOP;

    CLOSE cur_nilai;
END //

DELIMITER ;


-- 3. LATIHAN ERROR HANDLING: Prosedur cari_nama_matakuliah
-- Menangani kasus jika ID mata kuliah tidak ditemukan
DELIMITER //

CREATE PROCEDURE cari_nama_matakuliah(
    IN p_id_matakuliah INT,
    OUT p_nama_res VARCHAR(100)
)
BEGIN
    -- Handler untuk menangkap jika data tidak ditemukan
    DECLARE CONTINUE HANDLER FOR NOT FOUND 
        SET p_nama_res = 'Mata kuliah tidak ditemukan';

    -- Mencari nama mata kuliah
    SELECT nama_matakuliah INTO p_nama_res
    FROM matakuliah
    WHERE id_matakuliah = p_id_matakuliah;
END //

DELIMITER ;

-- 1. BERSIHKAN & BUAT ULANG TABEL 
CREATE TABLE IF NOT EXISTS mahasiswa (
    id_mahasiswa INT PRIMARY KEY, 
    nama_mahasiswa VARCHAR(100) NOT NULL,
    total_nilai INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS matakuliah (
    id_matakuliah INT PRIMARY KEY, 
    nama_matakuliah VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS nilai (
    id_nilai INT PRIMARY KEY AUTO_INCREMENT,
    id_mahasiswa INT, 
    id_matakuliah INT, 
    nilai INT,
    FOREIGN KEY (id_mahasiswa) REFERENCES mahasiswa(id_mahasiswa),
    FOREIGN KEY (id_matakuliah) REFERENCES matakuliah(id_matakuliah)
);

-- Tabel Log untuk menampung data yang dihapus (Tugas No. 2)
CREATE TABLE IF NOT EXISTS log_nilai (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_nilai_dihapus INT,
    nilai_lama INT,
    waktu_penghapusan DATETIME
);

-- 2. ISI DATA AWAL
INSERT IGNORE INTO mahasiswa (id_mahasiswa, nama_mahasiswa) VALUES (1, 'Budi'), (2, 'Siti');
INSERT IGNORE INTO matakuliah (id_matakuliah, nama_matakuliah) VALUES (1, 'Matematika'), (2, 'Fisika');
INSERT IGNORE INTO nilai (id_mahasiswa, id_matakuliah, nilai) VALUES (1, 1, 85), (2, 2, 40);


-- 3. TRIGGER TUGAS NO. 1: Blokir hapus jika nilai < 50
DELIMITER //
CREATE TRIGGER blokir_hapus_nilai_rendah
BEFORE DELETE ON nilai
FOR EACH ROW
BEGIN
    IF OLD.nilai < 50 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Data tidak boleh dihapus jika nilai di bawah 50!';
    END IF;
END //
DELIMITER ;


-- 4. TRIGGER TUGAS NO. 2: Catat ke tabel log setelah dihapus
DELIMITER //
CREATE TRIGGER log_penghapusan_nilai
AFTER DELETE ON nilai
FOR EACH ROW
BEGIN
    INSERT INTO log_nilai (id_nilai_dihapus, nilai_lama, waktu_penghapusan)
    VALUES (OLD.id_nilai, OLD.nilai, NOW());
END //
DELIMITER ;


-- 5. TRIGGER TUGAS NO. 3: Update total_nilai di tabel mahasiswa sebelum update
DELIMITER //
CREATE TRIGGER update_total_nilai_mahasiswa
BEFORE UPDATE ON mahasiswa
FOR EACH ROW
BEGIN
    SET NEW.total_nilai = (
        SELECT COALESCE(SUM(nilai), 0) 
        FROM nilai 
        WHERE id_mahasiswa = NEW.id_mahasiswa
    );
END //
DELIMITER ;