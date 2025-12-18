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