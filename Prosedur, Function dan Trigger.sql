CREATE TABLE mahasiswa 
(id_mahasiswa INT PRIMARY KEY, nama_mahasiswa VARCHAR(100) NOT NULL);

CREATE TABLE matakuliah 
(id_matakuliah INT PRIMARY KEY, nama_matakuliah VARCHAR(100) NOT NULL);

INSERT INTO mahasiswa (id_mahasiswa, nama_mahasiswa) VALUES 
(1, 'Budi'), (2, 'Siti'), (3, 'Agus');

INSERT INTO matakuliah (id_matakuliah, nama_matakuliah) VALUES 
(1, 'Matematika'), (2, 'Fisika'), (3, 'Kimia');

CREATE TABLE nilai 
(id_nilai INT PRIMARY KEY AUTO_INCREMENT, id_mahasiswa INT, id_matakuliah INT, nilai INT, 
FOREIGN KEY (id_mahasiswa) REFERENCES Mahasiswa(id_mahasiswa), 
FOREIGN KEY (id_matakuliah) REFERENCES MataKuliah(id_matakuliah));

INSERT INTO nilai (id_mahasiswa, id_matakuliah, nilai) VALUES 
(1, 1, 85), (2, 1, 90), (3, 2, 78);

SELECT  * FROM matakuliah

SELECT  * FROM nilai

-- CREATE OR REPLACE buat ngubah setelah terlanjur di run
CREATE OR REPLACE PROCEDURE tambah_nilai (
    IN p_id_mahasiswa INT,
    IN p_id_matakuliah INT,
    IN p_nilai INT
)
BEGIN
    INSERT INTO nilai (id_mahasiswa, id_matakuliah, id_nilai)
    VALUES (p_id_mahasiswa, p_id_matakuliah, p_nilai);
END;

CALL tambah_nilai(2, 2, 88);

-- PROCEDURE untuk UPDATE nilai
CREATE PROCEDURE update_nilai (
    IN p_id_mahasiswa INT,
    IN p_id_matakuliah INT,
    IN p_nilai INT
)
BEGIN
    UPDATE nilai
    SET nilai = p_nilai
    WHERE (id_mahasiswa = p_id_mahasiswa AND id_mahasiswa = p_id_matakuliah);
END;

CALL update_nilai(2, 2, 100);

SELECT * FROM nilai

CREATE OR REPLACE PROCEDURE delete_nilai (
    IN p_id_mahasiswa INT,
    IN p_id_matakuliah INT,
    IN p_nilai INT   
)
BEGIN
    DELETE FROM nilai
    WHERE (id_mahasiswa = p_id_mahasiswa AND id_mahasiswa = p_id_matakuliah);
END;

CALL delete_nilai(2, 2, 100);

-- Versi Pak Wildan
-- CREATE OR REPLACE PROCEDURE hapus_nilai (
--     IN p_id_mahasiswa INT,
--     IN p_id_matakuliah INT,  
-- )
-- BEGIN
--     UPDATE nilai
--     FROM (id_mahasiswa = p_id_mahasiswa AND id_mahasiswa = p_id_matakuliah);
-- END;

-- CALL delete_nilai(2, 2, 100);

CREATE FUNCTION hitung_rata_rata(
    p_id_mahasiswa INT
)
RETURNS DECIMAL (5,2)
DETERMINISTIC
BEGIN
    DECLARE rata_rata DECIMAL (5,2);
    SELECT AVG(nilai) INTO rata_rata
    FROM nilai
    WHERE id_mahasiswa = p_id_mahasiswa;
    RETURN COALESCE(rata_rata, 0);
END; 

-- FUNCTION akan mengembalikan nilai. jadi CALL diganti dengan SELECT
SELECT hitung_rata_rata(2);

CREATE OR REPLACE FUNCTION get_nama_matakuliah (
    p_id_matakuliah INT
)
RETURNS VARCHAR (100)
DETERMINISTIC
BEGIN
     DECLARE nama VARCHAR (100);
     SELECT nama_matakuliah INTO nama
     FROM matakuliah
     WHERE id_matakuliah = p_id_matakuliah;
     RETURN COALESCE (nama,'Tidak Ditemukan');
END;

SELECT get_nama_matakuliah(1);

-- DROP FUNCTION
-- DROP PROCEDURE

-- Ini coba-coba aja
CREATE OR REPLACE FUNCTION count_mahasiswa()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COALESCE(SUM(1), 0)
    INTO total
    FROM mahasiswa;
    RETURN total;
END;

SELECT count_mahasiswa();

-- Contoh Benar
CREATE OR REPLACE FUNCTION count_mahasiswa()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE jumlah INT;
    SELECT COUNT(*) INTO jumlah
    FROM mahasiswa;
    RETURN COALESCE(jumlah, 0);
END;

CREATE PROCEDURE cek_status_mahasiswa(
    IN p_id_mahasiswa INT,
    OUT p_status VARCHAR(50)
)
BEGIN
    DECLARE p_nilai_rata DECIMAL(5,2);

    SELECT AVG(nilai) INTO p_nilai_rata
    FROM nilai
    WHERE id_mahasiswa = p_id_mahasiswa;

    IF p_nilai_rata >= 85 THEN
        SET p_status = 'Sangat Baik';

    ELSEIF P_nilai_rata >= 70 THEN
        SET p_status = 'Baik';

    ELSE
        SET p_status = 'Perlu Peningkatan';
    END IF;
END;

CALL cek_status_mahasiswa(1,@status);
-- @ -> variabel tampung saat output belum ada

SELECT @status as "Status Nilai";

CREATE PROCEDURE kategori_mahasiswa(
    IN p_id_mahasiswa INT,
    OUT p_kategori VARCHAR(50)
)
BEGIN
    DECLARE p_nilai_rata DECIMAL (5,2);
-- Menghitung rata-rata nilai mahasiswa
    SELECT AVG(nilai) INTO p_nilai_rata
    FROM nilai
    WHERE id_mahasiswa = p_id_mahasiswa;
-- Tentukan kategori berdasarkan rata-rata nilai
    SET p_kategori = CASE
        WHEN p_nilai_rata >= 85 THEN 'Sangat Baik'
        WHEN p_nilai_rata >= 70 THEN 'Baik'
        ELSE 'Perlu Peningkatan'
    END;
END

CALL kategori_mahasiswa(1,@kategori);

SELECT @kategori as "Kategori Nilai";

CREATE TRIGGER after_insert_nilai
AFTER INSERT ON nilai
FOR EACH ROW
BEGIN
    INSERT INTO log_nilai (id_mahasiswa, id_matakuliah, nilai)
    VALUES (NEW.id_mahasiswa, NEW.id_matakuliah, NEW.nilai);
END;

INSERT INTO nilai (id_mahasiswa, id_matakuliah, nilai) VALUES (2, 3, 120);

CREATE TRIGGER before_insert_nilai
BEFORE INSERT ON nilai
FOR EACH ROW
BEGIN
    IF NEW.nilai < 0 OR NEW.nilai > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nilai harus antara 0 hingga 100';
    END IF;
END;

ALTER TABLE mahasiswa ADD rata_rata DECIMAL(5,2);

CREATE TRIGGER before_update_nilai
BEFORE UPDATE ON nilai
FOR EACH ROW
BEGIN
    DECLARE rata_rata DECIMAL(5,2);
    SELECT AVG(nilai) INTO rata_rata
    FROM nilai
    WHERE id_mahasiswa = NEW.id_mahasiswa;

    UPDATE mahasiswa
    SET rata_rata = rata_rata
    WHERE id_mahasiswa = NEW.id_mahasiswa;
END;

UPDATE nilai SET nilai = 95 WHERE id_nilai = 1;

SELECT * FROM mahasiswa;

-- Tugas baru: Menambahkan tabel log dan kolom baru

-- Tabel untuk menampung log penghapusan (Soal No. 2)
CREATE TABLE IF NOT EXISTS log_nilai (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_nilai_dihapus INT,
    nilai_lama INT,
    waktu_penghapusan DATETIME
);

-- Menambahkan kolom total_nilai ke tabel mahasiswa (Soal No. 3)
ALTER TABLE mahasiswa ADD COLUMN total_nilai INT DEFAULT 0;

-- 1. TRIGGER: memblokir penghapusan jika nilai < 50
DELIMITER //

CREATE TRIGGER blokir_hapus_nilai_rendah
BEFORE DELETE ON nilai
FOR EACH ROW
BEGIN
    -- Jika nilai yang akan dihapus kurang dari 50, batalkan proses
    IF OLD.nilai < 50 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Data tidak boleh dihapus jika nilai di bawah 50!';
    END IF;
END //

DELIMITER ;

-- 2. TRIGGER: Mencatat data yang dihapus ke tabel log
DELIMITER //

CREATE TRIGGER log_penghapusan_nilai
AFTER DELETE ON nilai
FOR EACH ROW
BEGIN
    -- Memasukkan data yang baru saja dihapus ke tabel log_nilai
    INSERT INTO log_nilai (id_nilai_dihapus, nilai_lama, waktu_penghapusan)
    VALUES (OLD.id_nilai, OLD.nilai, NOW());
END //

DELIMITER ;

-- 3. TRIGGER: Update total_nilai di tabel mahasiswa
DELIMITER //

CREATE TRIGGER update_total_nilai_mahasiswa
BEFORE UPDATE ON mahasiswa
FOR EACH ROW
BEGIN
    -- Menghitung total semua nilai milik mahasiswa tersebut dari tabel nilai
    SET NEW.total_nilai = (
        SELECT SUM(nilai) 
        FROM nilai 
        WHERE id_mahasiswa = NEW.id_mahasiswa
    );
END //

DELIMITER ;